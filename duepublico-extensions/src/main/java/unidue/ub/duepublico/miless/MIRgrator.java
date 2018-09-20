package unidue.ub.duepublico.miless;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.file.FileSystemException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.List;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.filter.ElementFilter;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRPersistenceException;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.content.MCRURLContent;
import org.mycore.common.content.transformer.MCRXSLTransformer;
import org.mycore.datamodel.common.MCRActiveLinkException;
import org.mycore.datamodel.ifs.MCRContentInputStream;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.niofs.MCRFileAttributes;
import org.mycore.datamodel.niofs.MCRPath;
import org.xml.sax.SAXException;

class MIRgrator {

    private static final String DUEPUBLICO_BASE = "https://duepublico.uni-due.de/";

    private static final String MCROBJ_URL = DUEPUBLICO_BASE + "receive/miless_mods_%s?XSL.Style=xml";

    private static final String DOCUMENT_URL = DUEPUBLICO_BASE
        + "servlets/DocumentServlet?action=retrieve&XSL.Style=xml&id=%s";

    private static final String DERIVATE_URL = DUEPUBLICO_BASE + "servlets/DerivateServlet/Derivate-%s/%s";

    private static final String DOCUMENT_XSL = "xsl/migration/miless2mir.xsl";

    String documentID;

    List<String> errors = new ArrayList<String>();

    MIRgrator(String documentID) {
        this.documentID = documentID;
    }

    List<String> getErrors() {
        return errors;
    }

    MCRObject mirgrate() throws JDOMException, IOException, SAXException, MCRPersistenceException, MCRAccessException,
        MCRActiveLinkException {
        Document milessDocument = getMilessDocument(documentID);
        Document mirObject = miless2mir(milessDocument);
        getErrors(mirObject);
        migrateServDates(documentID, mirObject);
        List<Element> eDerivates = detachChildren(mirObject.getRootElement(), "mycorederivate");
        MCRObject mcrObject = storeObject(mirObject);
        migrateDerivates(eDerivates);
        return mcrObject;
    }

    private Document getMilessDocument(String documentID) {
        try {
            URL url = new URL(String.format(DOCUMENT_URL, documentID));
            return new MCRURLContent(url).asXML();
        } catch (Exception ex) {
            throw new MIRgrationException("Exception retrieving metadata", ex);
        }
    }

    private Document miless2mir(Document milessDocument) {
        try {
            MCRXSLTransformer DocumentTransformer = MCRXSLTransformer.getInstance(DOCUMENT_XSL);
            MCRContent source = new MCRJDOMContent(milessDocument);
            MCRContent result = DocumentTransformer.transform(source);
            return result.asXML();
        } catch (Exception ex) {
            throw new MIRgrationException("Exception transforming metadata", ex);
        }
    }

    private void getErrors(Document milessDocument) {
        for (Element error : milessDocument.getRootElement().getDescendants(new ElementFilter("error"))) {
            errors.add(error.getText());
        }
        if (!errors.isEmpty()) {
            throw new MIRgrationException(errors.get(0), null);
        }
    }

    private void migrateServDates(String documentID, Document mirObject) {
        Element servDates = getServDates(documentID);
        mirObject.getRootElement().getChild("service").addContent(0, servDates);
    }

    private Element getServDates(String documentID) {
        try {
            URL url = new URL(String.format(MCROBJ_URL, documentID));
            MCRURLContent metadata = new MCRURLContent(url);
            return metadata.asXML().getRootElement().getChild("service").getChild("servdates").detach();
        } catch (Exception ex) {
            throw new MIRgrationException("Exception retrieving service dates", ex);
        }
    }

    private MCRObject storeObject(Document mirObject) {
        try {
            MCRObject mcrObject = new MCRObject(mirObject);
            mcrObject.setImportMode(true);
            MCRMetadataManager.update(mcrObject);
            return mcrObject;
        } catch (Exception ex) {
            throw new MIRgrationException("Exception saving migrated object", ex);
        }
    }

    private List<Element> detachChildren(Element parent, String name) {
        List<Element> copy = new ArrayList<Element>();
        copy.addAll(parent.getChildren(name));
        for (Element child : copy) {
            child.detach();
        }
        return copy;
    }

    private void migrateDerivates(List<Element> eDerivates)
        throws FileSystemException, IOException, MCRAccessException, MalformedURLException {
        for (Element eDerivate : eDerivates) {
            List<Element> eFiles = detachChildren(eDerivate, "file");

            MCRDerivate derivate = new MCRDerivate(new Document(eDerivate));
            derivate.setImportMode(true);
            MCRMetadataManager.update(derivate);

            MCRObjectID derivateID = derivate.getId();
            MCRPath rootDir = buildRootDir(derivateID);
            setIFSID(derivate, rootDir);
            MCRMetadataManager.updateMCRDerivateXML(derivate);

            for (Element eFile : eFiles) {
                String path = eFile.getChildText("path");

                MCRPath file = createFile(rootDir, path);
                MCRContent fileContent = getFileContent(derivateID, path);
                storeFileContent(file, fileContent);

                MCRFileAttributes attrs = Files.readAttributes(file, MCRFileAttributes.class);
                String expectedMD5 = eFile.getChildText("md5");
                if (!expectedMD5.equals(attrs.md5sum())) {
                    errors.add("MD5 sum mismatch: " + derivateID.toString() + "/" + path);
                }
            }
        }
    }

    private MCRPath buildRootDir(MCRObjectID derivateID) throws FileSystemException {
        MCRPath rootDir = MCRPath.getPath(derivateID.toString(), "/");
        if (Files.notExists(rootDir)) {
            rootDir.getFileSystem().createRoot(derivateID.toString());
        }
        return rootDir;
    }

    private void setIFSID(MCRDerivate derivate, MCRPath rootDir) throws IOException {
        BasicFileAttributes attrs = Files.readAttributes(rootDir, BasicFileAttributes.class);
        if (!(attrs.fileKey() instanceof String)) {
            throw new MCRPersistenceException(
                "Cannot get ID from newely created directory, as it is not a String." + rootDir);
        }
        derivate.getDerivate().getInternals().setIFSID(attrs.fileKey().toString());
    }

    private void storeFileContent(MCRPath file, MCRContent fileContent) throws IOException {
        MCRContentInputStream fIn = fileContent.getContentInputStream();
        Files.copy(fIn, file, StandardCopyOption.REPLACE_EXISTING);
        fIn.close();
    }

    private MCRContent getFileContent(MCRObjectID derivateID, String path) throws MalformedURLException {
        String url = String.format(DERIVATE_URL, derivateID.getNumberAsInteger(), path);
        return new MCRURLContent(new URL(url));
    }

    private MCRPath createFile(MCRPath rootDir, String path) throws IOException {
        MCRPath file = MCRPath.toMCRPath(rootDir.resolve(path));
        MCRPath parentDirectory = file.getParent();
        if (!Files.isDirectory(parentDirectory)) {
            Files.createDirectories(parentDirectory);
        }
        return file;
    }
}

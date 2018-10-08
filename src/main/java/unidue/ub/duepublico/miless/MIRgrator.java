package unidue.ub.duepublico.miless;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.file.FileSystemException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.attribute.FileTime;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
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

class MIRgrator {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String DUEPUBLICO_BASE = "https://duepublico.uni-due.de/";

    private static final String MCROBJ_URL = DUEPUBLICO_BASE + "receive/miless_mods_%s?XSL.Style=xml";

    private static final String DOCUMENT_URL = DUEPUBLICO_BASE
        + "servlets/DocumentServlet?action=retrieve&XSL.Style=xml&id=%s";

    private static final String DERIVATE_URL = DUEPUBLICO_BASE + "servlets/DerivateServlet/Derivate-%s/%s";

    private static final String[] DOCUMENT_XSLS = { "xsl/migration/miless2mir.xsl",
        "xsl/migration/html2altRepGroup.xsl" };

    String documentID;

    List<String> errors = new ArrayList<String>();

    MIRgrator(String documentID) {
        this.documentID = documentID;
    }

    List<String> getErrors() {
        return errors;
    }

    MCRObject mirgrate() throws MIRgrationException {
        LOGGER.info("Migrating document {}", documentID);

        Document milessDocument = getMilessDocument(documentID);
        Document mirObject = miless2mir(milessDocument);
        checkForErrorsIn(mirObject);
        migrateServDates(documentID, mirObject);
        List<Element> eDerivates = detachChildren(mirObject.getRootElement(), "mycorederivate");

        MCRObject mcrObject = null;
        try {
            mcrObject = storeObject(mirObject);
            migrateDerivates(eDerivates);
        } catch (MIRgrationException ex) {
            tryToRemoveInvalidObject(mcrObject);
            throw ex;
        }

        LOGGER.info("Migrated document to {}", mcrObject.getId().toString());
        return mcrObject;
    }

    private void tryToRemoveInvalidObject(MCRObject mcrObject) {
        if ((mcrObject != null) && MCRMetadataManager.exists(mcrObject.getId())) {
            try {
                MCRMetadataManager.deleteMCRObject(mcrObject.getId());
            } catch (MCRPersistenceException | MCRActiveLinkException | MCRAccessException ex2) {
                LOGGER.warn("Can not remove invalid migrated object", ex2);
            }
        }
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
            MCRXSLTransformer DocumentTransformer = MCRXSLTransformer.getInstance(DOCUMENT_XSLS);
            MCRContent source = new MCRJDOMContent(milessDocument);
            MCRContent result = DocumentTransformer.transform(source);
            return result.asXML();
        } catch (Exception ex) {
            throw new MIRgrationException("Exception transforming metadata", ex);
        }
    }

    private void checkForErrorsIn(Document milessDocument) {
        for (Element error : milessDocument.getRootElement().getDescendants(new ElementFilter("error"))) {
            errors.add(error.getText());
        }
        if (!errors.isEmpty()) {
            throw new MIRgrationException("Error in metadata conversion", null);
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

    private void migrateDerivates(List<Element> eDerivates) {
        for (Element eDerivate : eDerivates) {
            LOGGER.info("Migrating derivate {}", eDerivate.getAttributeValue("ID"));
            List<Element> eFiles = detachChildren(eDerivate, "file");

            MCRDerivate derivate = createDerivate(eDerivate);
            MCRPath rootDir = buildRootDir(derivate);

            for (Element eFile : eFiles) {
                migrateFile(derivate.getId(), rootDir, eFile);
            }
        }
    }

    private MCRDerivate createDerivate(Element eDerivate) {
        MCRDerivate derivate = new MCRDerivate(new Document(eDerivate));
        derivate.setImportMode(true);
        try {
            MCRMetadataManager.update(derivate);
        } catch (MCRPersistenceException | MCRAccessException ex) {
            throw new MIRgrationException("Exception creating derivate", ex);
        }
        return derivate;
    }

    private void migrateFile(MCRObjectID derivateID, MCRPath rootDir, Element eFile) {
        String path = eFile.getChildText("path");
        LOGGER.info("Migrating file {}", path);

        MCRPath file = createFile(rootDir, path);
        MCRContent fileContent = getFileContent(derivateID, path);
        storeFileContent(file, fileContent);
        keepFileLastModified(eFile, file);
        checkMD5(eFile, path, file);
    }

    private void checkMD5(Element eFile, String path, MCRPath file) {
        try {
            MCRFileAttributes<?> attrs = Files.readAttributes(file, MCRFileAttributes.class);
            String expectedMD5 = eFile.getChildText("md5");
            if (!expectedMD5.equals(attrs.md5sum())) {
                throw new MIRgrationException("MD5 sum mismatch: " + path, null);
            }
        } catch (IOException ex) {
            throw new MIRgrationException("Exception getting MD5 from file " + path, null);
        }
    }

    private void keepFileLastModified(Element eFile, MCRPath file) {
        try {
            Element eDate = eFile.getChild("date");
            DateFormat df = new SimpleDateFormat(eDate.getAttributeValue("format"));
            String sDateTime = eDate.getText();
            Date dateTime = df.parse(sDateTime);
            FileTime now = FileTime.fromMillis(dateTime.getTime());
            Files.setLastModifiedTime(file, now);
        } catch (Exception ignored) {
        }
    }

    private MCRPath buildRootDir(MCRDerivate derivate) {
        MCRPath rootDir = MCRPath.getPath(derivate.getId().toString(), "/");
        if (Files.notExists(rootDir)) {
            try {
                rootDir.getFileSystem().createRoot(derivate.getId().toString());
            } catch (FileSystemException ex) {
                throw new MIRgrationException("Exception building root directory", ex);
            }
        }
        setIFSID(derivate, rootDir);
        MCRMetadataManager.updateMCRDerivateXML(derivate);
        return rootDir;
    }

    private void setIFSID(MCRDerivate derivate, MCRPath rootDir) {
        try {
            BasicFileAttributes attrs = Files.readAttributes(rootDir, BasicFileAttributes.class);
            if (!(attrs.fileKey() instanceof String)) {
                throw new MIRgrationException("Cannot get ID from newly created root directory: " + rootDir, null);
            }
            derivate.getDerivate().getInternals().setIFSID(attrs.fileKey().toString());
        } catch (IOException ex) {
            throw new MIRgrationException("Exception setting IFS ID for derivate", null);
        }

    }

    private void storeFileContent(MCRPath file, MCRContent fileContent) {
        try {
            MCRContentInputStream fIn = fileContent.getContentInputStream();
            Files.copy(fIn, file, StandardCopyOption.REPLACE_EXISTING);
            fIn.close();
        } catch (IOException ex) {
            throw new MIRgrationException("Exception copying file content", ex);
        }
    }

    private MCRContent getFileContent(MCRObjectID derivateID, String path) {
        String url = String.format(DERIVATE_URL, derivateID.getNumberAsInteger(), path);
        try {
            return new MCRURLContent(new URL(url));
        } catch (MalformedURLException ex) {
            throw new MIRgrationException("Exception getting file content of " + derivateID + "/" + path, ex);
        }
    }

    private MCRPath createFile(MCRPath rootDir, String path) {
        MCRPath file = MCRPath.toMCRPath(rootDir.resolve(path));
        MCRPath parentDirectory = file.getParent();
        if (!Files.isDirectory(parentDirectory)) {
            try {
                Files.createDirectories(parentDirectory);
            } catch (IOException ex) {
                throw new MIRgrationException("Exception creating file " + path, ex);
            }
        }
        return file;
    }
}

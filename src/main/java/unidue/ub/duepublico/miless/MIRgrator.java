package unidue.ub.duepublico.miless;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
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
import org.mycore.common.MCRUtils;
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

    String documentID;

    MIRgrator(String documentID) {
        this.documentID = documentID;
    }

    List<String> errors = new ArrayList<String>();

    List<String> getErrors() {
        return errors;
    }

    private boolean justTesting = false;

    void setJustTesting(boolean justTesting) {
        this.justTesting = justTesting;
    }

    private boolean ignoreMetadataConversionErrors = false;

    void setIgnoreMetadataConversionErrors(boolean ignoreMetadataConversionErrors) {
        this.ignoreMetadataConversionErrors = ignoreMetadataConversionErrors;
    }

    MCRObject run() {
        if (justTesting) {
            LOGGER.info("Checking document {} for migration", documentID);
        } else {
            LOGGER.info("Migrating document {}", documentID);
        }

        MCRObject mcrObject = null;

        try {
            Document milessDocument = getMilessDocument(documentID);
            Document mirObject = miless2mir(milessDocument);
            collectErrors(mirObject);
            if (errors.isEmpty() || ignoreMetadataConversionErrors) {
                Element servDates = getServDates(documentID);
                setServDates(mirObject, servDates);

                List<Element> eDerivates = detachChildren(mirObject.getRootElement(), "mycorederivate");
                mcrObject = storeObject(mirObject);
                migrateDerivates(eDerivates);

                if (justTesting) {
                    LOGGER.info("Document {} can be migrated, use the following command:", documentID);
                    System.out.println("mirgrate document " + documentID + " testing false force false");
                } else {
                    LOGGER.info("Migrated document to {}", mcrObject.getId().toString());
                }
            }

        } catch (MIRgrationException ex) {
            tryToRemoveInvalidObject(mcrObject);

            errors.add(ex.getMessage());
            LOGGER.warn(ex);
        }

        for (String error : errors) {
            LOGGER.info("Error migrating document {}: {}", documentID, error);
        }

        return mcrObject;
    }

    private static final String DUEPUBLICO_BASE = "https://duepublico.uni-due.de/";

    private static final String DOCUMENT_URL = DUEPUBLICO_BASE
        + "servlets/DocumentServlet?action=retrieve&XSL.Style=xml&id=%s";

    private Document getMilessDocument(String documentID) {
        try {
            URL url = new URL(String.format(DOCUMENT_URL, documentID));
            return new MCRURLContent(url).asXML();
        } catch (Exception ex) {
            throw new MIRgrationException("Exception retrieving metadata", ex);
        }
    }

    private static final String[] DOCUMENT_XSLS = { "xsl/migration/miless2mir.xsl",
        "xsl/migration/html2altRepGroup.xsl" };

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

    private void collectErrors(Document mirObject) {
        List<Element> errorElements = new ArrayList<Element>();
        mirObject.getRootElement().getDescendants(new ElementFilter("error")).forEachRemaining(errorElements::add);
        errorElements.forEach(e -> {
            e.detach();
            errors.add(e.getText());
        });
    }

    private static final String MCROBJ_URL = DUEPUBLICO_BASE + "receive/miless_mods_%s?XSL.Style=xml";

    private Element getServDates(String documentID) {
        try {
            URL url = new URL(String.format(MCROBJ_URL, documentID));
            MCRURLContent metadata = new MCRURLContent(url);
            return metadata.asXML().getRootElement().getChild("service").getChild("servdates").detach();
        } catch (Exception ex) {
            throw new MIRgrationException("Exception retrieving service dates", ex);
        }
    }

    private void setServDates(Document mirObject, Element servDates) {
        mirObject.getRootElement().getChild("service").addContent(0, servDates);
    }

    private List<Element> detachChildren(Element parent, String name) {
        List<Element> copy = new ArrayList<Element>();
        copy.addAll(parent.getChildren(name));
        for (Element child : copy) {
            child.detach();
        }
        return copy;
    }

    private MCRObject storeObject(Document mirObject) {
        try {
            MCRObject mcrObject = new MCRObject(mirObject);
            mcrObject.setImportMode(true);
            if (!justTesting) {
                MCRMetadataManager.update(mcrObject);
            }
            return mcrObject;
        } catch (Exception ex) {
            throw new MIRgrationException("Exception saving migrated object", ex);
        }
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
        if (!justTesting) {
            try {
                MCRMetadataManager.update(derivate);
            } catch (MCRPersistenceException | MCRAccessException ex) {
                throw new MIRgrationException("Exception creating derivate", ex);
            }
        }
        return derivate;
    }

    private MCRPath buildRootDir(MCRDerivate derivate) {
        MCRPath rootDir = MCRPath.getPath(derivate.getId().toString(), "/");
        if (!justTesting) {
            if (Files.notExists(rootDir)) {
                try {
                    rootDir.getFileSystem().createRoot(derivate.getId().toString());
                } catch (FileSystemException ex) {
                    throw new MIRgrationException("Exception building root directory", ex);
                }
            }
            setIFSID(derivate, rootDir);
            MCRMetadataManager.updateMCRDerivateXML(derivate);
        }
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

    private void migrateFile(MCRObjectID derivateID, MCRPath rootDir, Element eFile) {
        String path = eFile.getChildText("path");
        LOGGER.info("Migrating file {}", path);

        MCRContent fileContent = getFileContent(derivateID, path);

        MCRPath file = null;
        if (!justTesting) {
            file = createFile(rootDir, path);
            storeFileContent(file, fileContent);
            keepFileLastModified(eFile, file);
        }
        checkMD5(eFile, path, fileContent, file);
    }

    private void checkMD5(Element eFile, String path, MCRContent fileContent, MCRPath file) {
        String expectedMD5 = eFile.getChildText("md5");
        String actualMD5;
        try {
            if (justTesting) {
                actualMD5 = MCRUtils.getMD5Sum(fileContent.getInputStream());
            } else {
                MCRFileAttributes<?> attrs = Files.readAttributes(file, MCRFileAttributes.class);
                actualMD5 = attrs.md5sum();
            }
        } catch (IOException ex) {
            throw new MIRgrationException("Error reading MD5 of " + path, ex);
        }

        if (!(expectedMD5.equals(actualMD5) || ignoreMetadataConversionErrors)) {
            throw new MIRgrationException("MD5 sum mismatch: " + path, null);
        }
    }

    private static final String DERIVATE_URL = DUEPUBLICO_BASE
        + "servlets/DerivateServlet/Derivate-%s/%s/_virtual/download/migration";

    private MCRContent getFileContent(MCRObjectID derivateID, String path) {
        try {
            path = URLEncoder.encode(path, StandardCharsets.UTF_8.name());
            path = path.replace("+", "%20").replace("%2F", "/");
        } catch (UnsupportedEncodingException willNotBeThrown) {
        }
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

    private void storeFileContent(MCRPath file, MCRContent fileContent) {
        try {
            MCRContentInputStream fIn = fileContent.getContentInputStream();
            Files.copy(fIn, file, StandardCopyOption.REPLACE_EXISTING);
            fIn.close();
        } catch (Exception ex) {
            throw new MIRgrationException("Exception copying file content", ex);
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
}

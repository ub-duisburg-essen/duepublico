package unidue.ub.duepublico.repec;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import javax.xml.transform.TransformerException;

import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.content.MCRSourceContent;
import org.mycore.common.xml.MCRLayoutService;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;
import org.xml.sax.SAXException;

/**
 * Implements <a href="https://ideas.repec.org/t/smap.html">RePEc interface</a>
 *
 * @author Frank Lützenkirchen
 */
@WebServlet(name = "RePEcServlet", urlPatterns = { "/RePEc", "/RePEc/*" })
public class RePEcServlet extends MCRServlet {

    private static final long serialVersionUID = 1L;

    private static final String CONFIG_BASE = "MCR.RePEc.";

    private static final String SLASH = "/";

    private static final String SUFFIX = ".redif";
    
    private static final String OBJ_METADATA_URI = "xslStyle:mycoreobject-redif-from-note:mcrobject:";

    private String seriesFileURI;

    private String findSeriesIDByRePEcID;

    private String archiveCode;
    
    private String archiveDirURI;
    
    private String seriesDirURI;

    private String fileArch;

    private String fileSeri;

    @Override
    public void init() throws ServletException {
        super.init();

        archiveCode = MCRConfiguration2.getString(CONFIG_BASE + "ArchiveCode").orElseThrow();
        fileArch = archiveCode + "arch" + SUFFIX;
        fileSeri = archiveCode + "seri" + SUFFIX;

        archiveDirURI = MCRConfiguration2.getString(CONFIG_BASE + "ArchiveDir.URI").orElseThrow();
        seriesDirURI = MCRConfiguration2.getString(CONFIG_BASE + "SeriesDir.URI").orElseThrow();
        
        seriesFileURI = MCRConfiguration2.getString(CONFIG_BASE + "SeriesFile.URI").orElseThrow();
        findSeriesIDByRePEcID = MCRConfiguration2.getString(CONFIG_BASE + "FindSeriesIDByRePEcID.SOLR").orElseThrow();
    }

    @Override
    protected void doGet(MCRServletJob job) throws Exception {
        HttpServletRequest req = job.getRequest();
        HttpServletResponse res = job.getResponse();
        String pathInfo = req.getPathInfo();

        if (pathInfo == null) {
            res.sendRedirect(req.getServletPath() + SLASH);
        } else if (SLASH.equals(pathInfo)) {
            sendRepecRoot(req, res);
        } else {
            pathInfo = pathInfo.substring(1);

            if (!pathInfo.startsWith(archiveCode)) {
                res.sendError(HttpServletResponse.SC_NOT_FOUND);
            } else {
                pathInfo = pathInfo.substring(archiveCode.length());

                if (pathInfo.isEmpty()) {
                    res.sendRedirect(archiveCode + SLASH);
                } else if (pathInfo.equals(SLASH)) {
                    sendArchiveDir(req, res);
                } else {
                    pathInfo = pathInfo.substring(1);

                    if (pathInfo.equals(fileArch)) {
                        sendArchiveFile(req, res);
                    } else if (pathInfo.equals(fileSeri)) {
                        sendSeriesFile(req, res);
                    } else if (!pathInfo.contains("/")) {
                        res.sendRedirect(pathInfo + SLASH);
                    } else {
                        String repecID = pathInfo.substring(0, pathInfo.indexOf(SLASH));
                        pathInfo = pathInfo.substring(pathInfo.indexOf(SLASH) + 1);

                        String objectID = getSeriesIDByRepecID(repecID);
                        if (objectID == null) {
                            res.sendError(HttpServletResponse.SC_NOT_FOUND);
                        } else if (pathInfo.isEmpty()) {
                            sendSeriesDir(req, res, objectID);
                        } else {
                            objectID = pathInfo.substring(0, pathInfo.indexOf(SUFFIX));
                            if (!MCRMetadataManager.exists(MCRObjectID.getInstance(objectID))) {
                                res.sendError(HttpServletResponse.SC_NOT_FOUND);
                            } else {
                                sendObjectMetadata(req, res, objectID);
                            }
                        }
                    }
                }
            }
        }
    }

    private void sendRepecRoot(HttpServletRequest req, HttpServletResponse res)
        throws IOException, TransformerException, SAXException {
        Element dir = new Element("node").setAttribute("name", archiveCode);
        Element repec = new Element("repec").addContent(dir);
        MCRLayoutService.instance().doLayout(req, res, new MCRJDOMContent(repec));
    }

    private void sendArchiveDir(HttpServletRequest req, HttpServletResponse res)
        throws IOException, TransformerException, SAXException {
        MCRContent content = MCRSourceContent.getInstance(archiveDirURI).getReusableCopy();
        MCRLayoutService.instance().doLayout(req, res, content);
    }

    private void sendArchiveFile(HttpServletRequest req, HttpServletResponse res)
        throws TransformerException, IOException, SAXException {
        MCRContent content = new MCRJDOMContent(new Element("redif-archive"));
        MCRLayoutService.instance().doLayout(req, res, content);
    }

    private String getSeriesIDByRepecID(String repecID)
        throws TransformerException, JDOMException, IOException, SAXException {
        String uri = findSeriesIDByRePEcID + repecID;
        return MCRSourceContent.getInstance(uri).asString().trim();
    }

    private void sendSeriesDir(HttpServletRequest req, HttpServletResponse res, String objectID)
        throws TransformerException, IOException, SAXException {
        String uri = String.format(seriesDirURI, objectID);
        MCRContent content = MCRSourceContent.getInstance(uri).getReusableCopy();
        MCRLayoutService.instance().doLayout(req, res, content);
    }

    private void sendSeriesFile(HttpServletRequest req, HttpServletResponse res)
        throws TransformerException, IOException, SAXException {
        MCRContent content = MCRSourceContent.getInstance(seriesFileURI);
        sendTextFile(res, content);
    }

    private void sendTextFile(HttpServletResponse res, MCRContent content) throws IOException {
        OutputStream out = res.getOutputStream();
        res.setCharacterEncoding(StandardCharsets.UTF_8.displayName());
        res.setContentType("text/plain");
        content.sendTo(out);
        out.close();
    }

    private void sendObjectMetadata(HttpServletRequest req, HttpServletResponse res, String objectID)
        throws TransformerException, IOException, SAXException {
        String uri = OBJ_METADATA_URI + objectID;
        MCRContent content = MCRSourceContent.getInstance(uri);
        sendTextFile(res, content);
    }
}

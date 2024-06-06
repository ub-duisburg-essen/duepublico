package unidue.ub.duepublico.repec;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
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
 * @author Frank L\u00FCtzenkirchen
 */
@WebServlet(name = "RePEcServlet", urlPatterns = { "/RePEc", "/RePEc/*" })
public class RePEcServlet extends MCRServlet {

    private static final long serialVersionUID = 1L;

    private static final String CONFIG_BASE = "MCR.RePEc.";

    private static final String SLASH = "/";

    private static final String SUFFIX = ".redif";

    private String allSeriesURI;

    private String findSeriesIDByRePEcID;

    private String findSeriesChildrenByID;

    private String archiveCode;

    private String fileArch;

    private String fileSeri;

    @Override
    public void init() throws ServletException {
        super.init();

        archiveCode = MCRConfiguration2.getString(CONFIG_BASE + "ArchiveCode").orElseThrow();
        fileArch = archiveCode + "arch" + SUFFIX;
        fileSeri = archiveCode + "seri" + SUFFIX;

        allSeriesURI = MCRConfiguration2.getString(CONFIG_BASE + "URI.AllSeries").orElseThrow();
        findSeriesIDByRePEcID = MCRConfiguration2.getString(CONFIG_BASE + "URI.FindSeriesIDByRePEcID").orElseThrow();
        findSeriesChildrenByID = MCRConfiguration2.getString(CONFIG_BASE + "URI.FindSeriesChildrenByID").orElseThrow();
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
                    sendArchiveDirectory(req, res);
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
        MCRContent content = new MCRJDOMContent(new Element("repec-root"));
        MCRLayoutService.instance().doLayout(req, res, content);
    }

    private void sendArchiveFile(HttpServletRequest req, HttpServletResponse res)
        throws TransformerException, IOException, SAXException {
        MCRContent content = new MCRJDOMContent(new Element("repec-archive"));
        MCRLayoutService.instance().doLayout(req, res, content);
    }

    private void sendArchiveDirectory(HttpServletRequest req, HttpServletResponse res)
        throws IOException, TransformerException, SAXException {
        req.setAttribute("XSL.Style", "repec-dir");
        req.setAttribute("XSL.Mode", "archive");
        MCRLayoutService.instance().doLayout(req, res, MCRSourceContent.getInstance(allSeriesURI));
    }

    private void sendSeriesFile(HttpServletRequest req, HttpServletResponse res)
        throws TransformerException, IOException, SAXException {
        req.setAttribute("XSL.Style", "repec-file");
        MCRLayoutService.instance().doLayout(req, res, MCRSourceContent.getInstance(allSeriesURI));
    }

    private String getSeriesIDByRepecID(String repecID)
        throws TransformerException, JDOMException, IOException, SAXException {
        String uri = String.format(findSeriesIDByRePEcID, repecID);
        MCRContent solrResponse = MCRSourceContent.getInstance(uri);
        Element doc = solrResponse.asXML().getRootElement().getChild("result").getChild("doc");
        return (doc == null ? null : doc.getChild("str").getTextTrim());
    }

    private void sendSeriesDir(HttpServletRequest req, HttpServletResponse res, String objectID)
        throws TransformerException, IOException, SAXException {
        String uri = String.format(findSeriesChildrenByID, objectID);
        MCRContent solrResponse = MCRSourceContent.getInstance(uri);
        req.setAttribute("XSL.Style", "repec-dir");
        req.setAttribute("XSL.Mode", "series");
        MCRLayoutService.instance().doLayout(req, res, solrResponse);
    }

    private void sendObjectMetadata(HttpServletRequest req, HttpServletResponse res, String objectID)
        throws TransformerException, IOException, SAXException {
        String uri = "mcrobject:" + objectID;
        MCRContent obj = MCRSourceContent.getInstance(uri).getReusableCopy();
        req.setAttribute("XSL.Style", "redif");
        MCRLayoutService.instance().doLayout(req, res, obj);
    }
}

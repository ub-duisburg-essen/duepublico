package unidue.ub.duepublico.miless;

import java.io.IOException;
import java.net.URL;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.filter.ElementFilter;
import org.jdom2.util.IteratorIterable;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRPersistenceException;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.content.MCRURLContent;
import org.mycore.common.content.transformer.MCRXSLTransformer;
import org.mycore.common.xml.MCRLayoutService;
import org.mycore.datamodel.common.MCRActiveLinkException;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;
import org.xml.sax.SAXException;

public class MIRgrationServlet extends MCRServlet {

    private static final long serialVersionUID = 1L;

    private static final String DUEPUBLICO_BASE = "https://duepublico.uni-due.de/";

    private static final String MCROBJ_URL = DUEPUBLICO_BASE + "receive/miless_mods_%s?XSL.Style=xml";

    private static final String DOCUMENT_URL = DUEPUBLICO_BASE
        + "servlets/DocumentServlet?action=retrieve&XSL.Style=xml&id=%s";

    private static final String DOCUMENT_XSL = "xsl/migration/miless2mir.xsl";

    @Override
    protected void doGetPost(MCRServletJob job) throws Exception {
        String documentID = job.getRequest().getParameter("id");

        Document milessDocument = getMilessDocument(documentID);
        Document mirObject = miless2mir(milessDocument);

        Document errors = getErrors(milessDocument);
        if (errors != null) {
            MCRLayoutService.instance().sendXML(job.getRequest(), job.getResponse(), new MCRJDOMContent(errors));
            return;
        }

        Element servDates = getServDates(documentID);
        mirObject.getRootElement().getChild("service").addContent(0, servDates);

        MCRObject mcrObject = storeObject(mirObject);

        String msg = "?XSL.Status.Message=duepublico.mirgrated&XSL.Status.Style=info";
        job.getResponse().sendRedirect("../receive/" + mcrObject.getId().toString() + msg);
    }

    private Document getMilessDocument(String documentID) throws JDOMException, IOException, SAXException {
        URL url = new URL(String.format(DOCUMENT_URL, documentID));
        return new MCRURLContent(url).asXML();
    }

    private Document miless2mir(Document milessDocument) throws IOException, JDOMException, SAXException {
        MCRXSLTransformer DocumentTransformer = MCRXSLTransformer.getInstance(DOCUMENT_XSL);
        MCRContent source = new MCRJDOMContent(milessDocument);
        MCRContent result = DocumentTransformer.transform(source);
        return result.asXML();
    }

    private Document getErrors(Document milessDocument) {
        IteratorIterable<Element> errors = milessDocument.getRootElement().getDescendants(new ElementFilter("error"));
        if (!errors.hasNext()) {
            return null;
        }

        Element report = new Element("errors");
        for (Element error : errors) {
            report.addContent(error.clone());
        }
        return new Document(report);
    }

    private Element getServDates(String documentID) throws JDOMException, IOException, SAXException {
        URL url = new URL(String.format(MCROBJ_URL, documentID));
        MCRURLContent metadata = new MCRURLContent(url);
        return metadata.asXML().getRootElement().getChild("service").getChild("servdates").detach();
    }

    private MCRObject storeObject(Document mirObject)
        throws MCRAccessException, MCRPersistenceException, MCRActiveLinkException {
        MCRObject mcrObject = new MCRObject(mirObject);
        mcrObject.setImportMode(true);
        MCRMetadataManager.update(mcrObject);
        return mcrObject;
    }
}

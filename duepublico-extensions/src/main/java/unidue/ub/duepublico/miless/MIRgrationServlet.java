package unidue.ub.duepublico.miless;

import java.io.IOException;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.xml.MCRLayoutService;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;

public class MIRgrationServlet extends MCRServlet {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGetPost(MCRServletJob job) throws Exception {
        String documentID = job.getRequest().getParameter("id");
        LOGGER.info("Migrating document {}", documentID);

        MIRgrator mirgrator = new MIRgrator(documentID);
        try {
            MCRObject object = mirgrator.mirgrate();
            redirectToMigratedObject(job, object.getId());
        } catch (Exception ex) {
            LOGGER.warn(ex);

            if (!mirgrator.getErrors().isEmpty()) {
                reportErrors(job, mirgrator.getErrors());
            }
        }
    }

    private void reportErrors(MCRServletJob job, List<String> errors) throws IOException {
        Element report = new Element("errors");
        for (String error : errors) {
            LOGGER.warn("Error: {}", error);
            report.addContent(new Element("error").setText(error));
        }
        MCRLayoutService.instance().sendXML(job.getRequest(), job.getResponse(), new MCRJDOMContent(report));
    }

    private void redirectToMigratedObject(MCRServletJob job, MCRObjectID id) throws IOException {
        LOGGER.info("Document successfully migrated to {}", id.toString());
        String msg = "?XSL.Status.Message=duepublico.mirgrated&XSL.Status.Style=info";
        String url = MCRFrontendUtil.getBaseURL() + "receive/" + id.toString() + msg;
        job.getResponse().sendRedirect(url);
    }
}

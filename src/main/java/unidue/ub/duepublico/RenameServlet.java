package unidue.ub.duepublico;

import static org.mycore.access.MCRAccessManager.PERMISSION_WRITE;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.text.MessageFormat;
import java.text.Normalizer;
import java.text.Normalizer.Form;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.access.MCRAccessException;
import org.mycore.access.MCRAccessManager;
import org.mycore.common.MCRPersistenceException;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetaIFS;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.niofs.MCRPath;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;
import org.mycore.mods.merger.MCRHyphenNormalizer;

/**
 * Renames a file in a derivate
 *
 * @author Frank L\u00FCtzenkirchen
 */
@WebServlet(name = "RenameServlet", urlPatterns = { "/servlets/RenameServlet" })
public class RenameServlet extends MCRServlet {

    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = LogManager.getLogger();

    @Override
    protected void doGetPost(MCRServletJob job) throws Exception {
        HttpServletRequest req = job.getRequest();
        HttpServletResponse res = job.getResponse();

        String id = req.getParameter("id");
        MCRObjectID derivateID = MCRObjectID.getInstance(id);
        if (!MCRMetadataManager.exists(derivateID)) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Derivate with ID " + id + " does not exist!");
            return;
        }

        if (!MCRAccessManager.checkPermission(derivateID, PERMISSION_WRITE)) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, MessageFormat.format("User has not the \""
                + PERMISSION_WRITE + "\" permission on derivate {0}.", derivateID));
            return;
        }

        MCRDerivate derivate = MCRMetadataManager.retrieveMCRDerivate(derivateID);

        String fromPath = req.getParameter("path");
        if (fromPath == null || fromPath.isEmpty()
            || (fromPath = fromPath.replaceAll("^/", "").replaceAll("/$", "")).isEmpty()) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Parameter 'path' is empty!");
            return;
        }

        Path rootDir = MCRPath.getPath(derivateID.toString(), "/");
        Path fromFile = MCRPath.toMCRPath(rootDir.resolve(fromPath));
        if (!Files.exists(fromFile)) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST, "File " + fromPath + " does not exist!");
            return;
        }

        String toPath = req.getParameter("to");
        if (toPath == null || toPath.isEmpty()) {
            toPath = normalizeFileName(fromPath);
        } else {
            toPath = toPath.trim().replaceAll("^/", "").replaceAll("/$", "");
        }

        if (!fromPath.equals(toPath)) {
            Path toFile = fromFile.resolveSibling(toPath);
            if (Files.exists(toFile)) {
                res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Target file " + toPath + " already exists!");
                return;
            }

            LOGGER.info("Renaming file \"{}\" to \"{}\" in {}", fromPath, toPath, id);
            Files.move(fromFile, toFile);
            updateMainFile(derivate, fromPath, toPath);
        }

        redirectToObject(res, derivate);
    }

    private void redirectToObject(HttpServletResponse res, MCRDerivate derivate) throws IOException {
        MCRObjectID oid = derivate.getOwnerID();
        String url = MCRFrontendUtil.getBaseURL() + "receive/" + oid.toString();
        res.sendRedirect(res.encodeRedirectURL(url));
    }

    private void updateMainFile(MCRDerivate derivate, String fromPath, String toPath) {
        MCRMetaIFS mi = derivate.getDerivate().getInternals();
        String mainFile = mi.getMainDoc();
        if (mainFile.equals(fromPath)) {
            mi.setMainDoc(toPath);
            
            try {
                MCRMetadataManager.update(derivate);
            } catch (MCRPersistenceException | MCRAccessException exc) {
                LOGGER.warn("Can not update main file", exc);
            }
        }
    }

    private String normalizeFileName(String toName) {
        toName = toName.trim(); // remove leading/trailing spaces
        toName = toName.replaceAll("\\s+", "_"); // spaces to underscore
        toName = new MCRHyphenNormalizer().normalize(toName); // normalize hyphen variants
        toName = toName.replace("ß", "ss"); // resolve umlaut characters
        toName = toName.replace("ä", "ae").replace("ö", "oe").replace("ü", "ue");
        toName = toName.replace("Ä", "Ae").replace("Ö", "Oe").replace("Ü", "Ue");
        toName = Normalizer.normalize(toName, Form.NFD).replaceAll("\\p{M}", ""); // canonical decomposition, then remove accents
        toName = toName.replaceAll("[^A-Za-z0-9_\\-\\.]", ""); // no ugly characters
        return toName;
    }
}

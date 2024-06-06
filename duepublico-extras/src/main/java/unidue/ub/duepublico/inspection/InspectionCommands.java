package unidue.ub.duepublico.inspection;

import org.apache.logging.log4j.Logger;

import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.mycore.common.MCRSession;
import org.mycore.common.MCRSessionMgr;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.frontend.cli.MCRAbstractCommands;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.user2.MCRUserManager;

/** Commands for inspect running duepublico environment */
@MCRCommandGroup(name = "Inspection commands")
public class InspectionCommands extends MCRAbstractCommands {
    private final static Logger LOGGER = LogManager.getLogger(InspectionCommands.class);

    /**
     * Implements command to inspect all metadata pages for given mycore type based on http status codes 
     * @param type
     * @throws Exception
     */
    @org.mycore.frontend.cli.annotation.MCRCommand(
        syntax = "inspect all metadata pages for type {0} with set current user on {1}",
        help = "inspect all metadata pages for type mods with set current user on true (use false to inspect metadata pages for unlogged user)",
        order = 10)
    public static void inspectMetadataPages(String type, String isCurrentUser) throws Exception {

        LOGGER.info("Getting all MCRObjectIDs stored for type " + type);
        List<String> listIds = MCRXMLMetadataManager.instance().listIDsOfType(type);

        LOGGER.info("Inspect " + listIds.size() + " metadata pages.");

        String jsessionid = "";
        int invalidConnections = 0;

        boolean isCurrentUserSetting = isCurrentUser != null && isCurrentUser.toLowerCase().equals("true")
            && MCRSessionMgr.hasCurrentSession() && MCRUserManager.getCurrentUser() != null;

        if (isCurrentUserSetting) {
            LOGGER.info("Receive metadata pages for current User: " + MCRUserManager.getCurrentUser().getUserName());

            MCRSession session = MCRSessionMgr.getCurrentSession();
            jsessionid = (String) session.get("http.session");
        } else {
            LOGGER.info(
                "Current user parameter is false or there is no MCR Session Object. Receive metadata pages for GUEST.");
        }

        for (String currentId : listIds) {

            URL url = new URL(MCRFrontendUtil.getBaseURL() + "receive/" + currentId);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();

            if (isCurrentUserSetting) {
                connection.setRequestProperty(
                    "Cookie", "JSESSIONID=" + jsessionid);
            }

            connection.setRequestMethod("GET");
            connection.connect();

            int code = connection.getResponseCode();
            if (code != 200) {
                LOGGER.info("Failed to get " + url.toString() + " with http code: " + code);
                invalidConnections++;
            }
        }

        LOGGER.info(invalidConnections + " connections with no http-200 have been found.");
    }
}

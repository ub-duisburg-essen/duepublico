package unidue.ub.duepublico.login;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUser2Constants;
import org.mycore.user2.MCRUserManager;

/**
 * Used in combination with authorization/login.xed to implement a cascading login for local and LDAP users.
 *
 * @author Frank L\u00FCtzenkirchen
 */
public class CascadingLoginServlet extends MCRServlet {

    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String HTTPS_ONLY_PROPERTY = MCRUser2Constants.CONFIG_PREFIX + "LoginHttpsOnly";

    private static final boolean LOCAL_LOGIN_SECURE_ONLY = MCRConfiguration.instance().getBoolean(HTTPS_ONLY_PROPERTY);

    private static AuthenticationHandler AUTH_HANDLER = new CascadingAuthenticationHandler();

    @Override
    protected void doPost(MCRServletJob job) throws Exception {
        HttpServletRequest req = job.getRequest();
        HttpServletResponse res = job.getResponse();

        if (LOCAL_LOGIN_SECURE_ONLY && !req.isSecure()) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, getErrorI18N("component.user2.login", "httpsOnly"));
            return;
        }

        Document doc = (Document) (req.getAttribute("MCRXEditorSubmission"));
        if (doc == null) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST, "login form submission expected");
            return;
        }

        String uid = doc.getRootElement().getChildText("uid");
        String pwd = doc.getRootElement().getChildText("pwd");

        if ((uid == null) || (pwd == null) || uid.isEmpty() || pwd.isEmpty()) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST, "missing uid/pwd in login form submission");
            return;
        }

        MCRUser user = AUTH_HANDLER.authenticate(uid, pwd);

        if (user != null) {
            LOGGER.info("Login of user " + uid + " from " + user.getRealmID() + " successful");

            user.setLastLogin();
            MCRUserManager.updateUser(user);
            MCRSessionMgr.getCurrentSession().setUserInformation(user);

            redirect(req, res);
        } else {
            LOGGER.info("Login of user " + uid + " failed");
            job.getResponse().sendError(HttpServletResponse.SC_UNAUTHORIZED);
        }
    }

    /**
     * Used by login.xed to validate userID and password combination.
     *
     * @param login the XML element from the XEditor form containing containing uid and pwd.
     */
    public static boolean validateLogin(Element login) throws Exception {
        String uid = login.getChildText("uid");
        String pwd = login.getChildText("pwd");

        if ((uid == null) || (pwd == null) || uid.isEmpty() || pwd.isEmpty()) {
            return true;
        } else {
            return AUTH_HANDLER.authenticate(uid, pwd) != null;
        }
    }

    /**
     * Redirects the browser to the target url after successful login.
     */
    private static void redirect(HttpServletRequest req, HttpServletResponse res) throws Exception {
        String url = req.getParameter("url");
        if (url == null) {
            url = MCRFrontendUtil.getBaseURL();
        }
        res.sendRedirect(res.encodeRedirectURL(url));
    }
}

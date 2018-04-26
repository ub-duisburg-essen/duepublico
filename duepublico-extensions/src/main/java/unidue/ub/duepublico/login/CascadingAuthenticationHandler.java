package unidue.ub.duepublico.login;

import java.util.ArrayList;
import java.util.List;

import org.mycore.common.config.MCRConfiguration;
import org.mycore.user2.MCRUser;

/**
 * Checks the given user ID and password combination against multiple other
 * authentication handlers in configurable order. The first successful login wins.
 *
 * The types and order of authentication handlers is configured by realm IDs, e.g.
 * MCR.user2.CascadingLogin.Realms=local ldap
 *
 * For each realm, the authentication handler to be used must be configured, e.g.
 *
 * MCR.user2.CascadingLogin.local=unidue.ub.duepublico.login.LocalAuthenticationHandler
 * MCR.user2.CascadingLogin.ldap=unidue.ub.duepublico.login.LDAPAuthenticationHandler
 */
public class CascadingAuthenticationHandler extends AuthenticationHandler {

    private static final String CONFIG_PREFIX = "MCR.user2.CascadingLogin.";

    private List<AuthenticationHandler> authenticationHandlers;

    public CascadingAuthenticationHandler() {
        init("cascading");

        authenticationHandlers = new ArrayList<AuthenticationHandler>();

        MCRConfiguration config = MCRConfiguration.instance();
        String[] realmIDs = config.getString(CONFIG_PREFIX + "Realms").split("\\s");
        for (String realmID : realmIDs) {
            AuthenticationHandler handler = config.getInstanceOf(CONFIG_PREFIX + realmID);
            handler.init(realmID);
            authenticationHandlers.add(handler);
        }
    }

    public MCRUser authenticate(String uid, String pwd) throws Exception {
        for (AuthenticationHandler handler : authenticationHandlers) {
            MCRUser user = handler.authenticate(uid, pwd);
            if (user != null) {
                return user;
            }
        }
        return null;
    }
}

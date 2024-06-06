package unidue.ub.duepublico.login;

import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserManager;

/**
 * Checks the given user ID and password combination against local realm
 * and returns the user if authentication is OK.
 *
 * @author Frank L\u00FCtzenkirchen
 */
public class LocalAuthenticationHandler extends AuthenticationHandler {

    public MCRUser authenticate(String uid, String pwd) {
        return MCRUserManager.checkPassword(uid, pwd);
    }
}

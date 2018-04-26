package unidue.ub.duepublico.login;

import org.mycore.user2.MCRUser;

/**
 * Represents a method to check the given user ID and password combination
 * and return the user if authentication is OK.
 *
 * @author Frank L\u00FCtzenkirchen
 */
public abstract class AuthenticationHandler {

    /** The realm used for this login method */
    protected String realmID;

    /**
     * @param realmID the realm used for this login method
     */
    public void init(String realmID) {
        this.realmID = realmID;
    }

    /**
     * Returns the user for the given user ID and password,
     * or null if no such user exists or the password is invalid.
     */
    public abstract MCRUser authenticate(String uid, String pwd) throws Exception;
}

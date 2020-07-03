package unidue.ub.duepublico.login;

import java.util.Hashtable;
import java.util.Locale;
import java.util.Optional;

import javax.naming.AuthenticationException;
import javax.naming.Context;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;
import javax.naming.directory.DirContext;
import javax.naming.directory.InitialDirContext;
import javax.naming.directory.SearchControls;
import javax.naming.directory.SearchResult;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUser2Constants;
import org.mycore.user2.MCRUserManager;

/**
 * Checks the given user ID and password combination against remote LDAP server
 * and returns the user if authentication is OK. Configuration is done via mycore.properties:
 *
 * # LDAP server
 * MCR.user2.LDAP.ProviderURL=ldaps://ldap2.uni-duisburg-essen.de

 * # Timeout when connecting to LDAP server
 * MCR.user2.LDAP.ReadTimeout=5000
 *
 * # Base DN, uid of user on actual login will be used!
 * # We do not use any "global" credentials, just the user's own uid and password to connect
 * MCR.user2.LDAP.BaseDN=uid=%s,ou=people,dc=uni-duisburg-essen,dc=de
 *
 * # Filter for user ID
 * MCR.user2.LDAP.UIDFilter=(uid=%s)
 *
 * # Mapping from LDAP attribute to real name of user
 * MCR.user2.LDAP.Mapping.Name=cn
 *
 * # Mapping from LDAP attribute to E-Mail address of user
 * MCR.user2.LDAP.Mapping.E-Mail=mail
 *
 * # Default group membership (optional) for any successful login
 * MCR.user2.LDAP.Mapping.Group.DefaultGroup=submitter
 *
 * # Mapping of any attribute.value combination to group membership of user
 * # eduPersonScopedAffiliation may be faculty|staff|employee|student|alum|member|affiliate
 * MCR.user2.LDAP.Mapping.Group.eduPersonScopedAffiliation.staff@uni-duisburg-essen.de=submitter
 *
 * @author Frank L\u00FCtzenkirchen
 */
public class LDAPAuthenticationHandler extends AuthenticationHandler {

    /** If this pattern is given in LDAP error message, login is invalid */
    private static final String PATTERN_INVALID_CREDENTIALS = "error code 49";

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String CONFIG_PREFIX = MCRUser2Constants.CONFIG_PREFIX + "LDAP.";

    /** Base DN, uid of user on actual login will be used! */
    private String baseDN;

    /** Filter for user ID */
    private String uidFilter;

    /** LDAP configuration template */
    private Hashtable<String, String> ldapEnvironment;

    /** Mapping from LDAP attribute to real name of user */
    private String mapName;

    /** Mapping from LDAP attribute to E-Mail address of user */
    private String mapEMail;

    public LDAPAuthenticationHandler() {
        ldapEnvironment = new Hashtable<>();
        ldapEnvironment.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");

        String readTimeout = MCRConfiguration2.getString(CONFIG_PREFIX + "ReadTimeout").orElse("10000");
        ldapEnvironment.put("com.sun.jndi.ldap.read.timeout", readTimeout);

        String providerURL = MCRConfiguration2.getString(CONFIG_PREFIX + "ProviderURL").get();
        ldapEnvironment.put(Context.PROVIDER_URL, providerURL);
        if (providerURL.startsWith("ldaps")) {
            ldapEnvironment.put(Context.SECURITY_PROTOCOL, "ssl");
        }

        ldapEnvironment.put(Context.SECURITY_AUTHENTICATION, "simple");

        baseDN = MCRConfiguration2.getString(CONFIG_PREFIX + "BaseDN").get();
        uidFilter = MCRConfiguration2.getString(CONFIG_PREFIX + "UIDFilter").get();

        mapName = MCRConfiguration2.getString(CONFIG_PREFIX + "Mapping.Name").get();
        mapEMail = MCRConfiguration2.getString(CONFIG_PREFIX + "Mapping.E-Mail").get();
    }

    public MCRUser authenticate(String uid, String pwd) throws Exception {
        DirContext ctx = null;

        try {
            ctx = getDirContext(uid, pwd);
            if (ctx == null) {
                return null;
            }

            LOGGER.debug("Login of " + uid + " via LDAP was successful");

            MCRUser user = MCRUserManager.getUser(uid, realmID);
            if (user != null) {
                LOGGER.debug("User " + uid + " already known in store");
            } else {
                LOGGER.debug("User " + uid + " unknown in store, will create");
                user = new MCRUser(uid, realmID);
                MCRUserManager.createUser(user);
            }
            setUserAttributes(ctx, user);

            return user;
        } finally {
            if (ctx != null) {
                try {
                    ctx.close();
                } catch (NamingException ex) {
                    LOGGER.warn("could not close context " + ex);
                }
            }
        }
    }

    @SuppressWarnings("unchecked")
    private DirContext getDirContext(String uid, String credentials) throws NamingException {
        try {
            Hashtable<String, String> env = (Hashtable<String, String>) (ldapEnvironment.clone());
            env.put(Context.SECURITY_PRINCIPAL, String.format(baseDN, uid));
            env.put(Context.SECURITY_CREDENTIALS, credentials);
            return new InitialDirContext(env);
        } catch (AuthenticationException ex) {
            if (ex.getMessage().contains(PATTERN_INVALID_CREDENTIALS)) {
                LOGGER.debug("Could not authenticate LDAP user " + uid + ": " + ex.getMessage());
                return null;
            } else {
                throw ex;
            }
        }
    }

    /**
     * Sets the MCRUser's name, e-mail and groups by mapping LDAP attributes.
     */
    private void setUserAttributes(DirContext ctx, MCRUser user) throws NamingException {
        addToGroup(user, CONFIG_PREFIX + "Mapping.Group.DefaultGroup");

        SearchControls controls = new SearchControls();
        controls.setSearchScope(SearchControls.SUBTREE_SCOPE);

        String uid = user.getUserName();
        String principal = String.format(baseDN, uid);
        String filter = String.format(Locale.ROOT, uidFilter, uid);

        NamingEnumeration<SearchResult> results = ctx.search(principal, filter, controls);

        while (results.hasMore()) {
            SearchResult searchResult = results.next();
            Attributes attributes = searchResult.getAttributes();

            for (NamingEnumeration<String> attributeIDs = attributes.getIDs(); attributeIDs.hasMore();) {
                String attributeID = attributeIDs.next();
                Attribute attribute = attributes.get(attributeID);

                for (NamingEnumeration<?> values = attribute.getAll(); values.hasMore();) {
                    String attributeValue = values.next().toString().trim();
                    LOGGER.debug(attributeID + "=" + attributeValue);

                    setUserRealName(user, attributeID, attributeValue);
                    setUserEMail(user, attributeID, attributeValue);
                    addToGroup(user, CONFIG_PREFIX + "Mapping.Group." + attributeID + "." + attributeValue);
                }
            }
        }
    }

    private void setUserEMail(MCRUser user, String attributeID, String attributeValue) {
        if (attributeID.equals(mapEMail) && (user.getEMailAddress() == null)) {
            LOGGER.debug("User " + user.getUserName() + " e-mail = " + attributeValue);
            user.setEMail(attributeValue);
        }
    }

    private void setUserRealName(MCRUser user, String attributeID, String attributeValue) {
        if (attributeID.equals(mapName) && (user.getRealName() == null)) {
            attributeValue = formatName(attributeValue);
            LOGGER.debug("User " + user.getUserName() + " name = " + attributeValue);
            user.setRealName(attributeValue);
        }
    }

    private void addToGroup(MCRUser user, String groupMapping) {
        Optional<String> mappedGroup = MCRConfiguration2.getString(groupMapping);
        if (mappedGroup.isPresent()) {
            String group = mappedGroup.get();
            if (!user.isUserInRole(group)) {
                LOGGER.info("Add user " + user.getUserName() + " to group " + group);
                user.assignRole(group);

            }
        }
    }

    /** Formats a user name into "lastname, firstname" syntax. */
    private static String formatName(String name) {
        name = name.replaceAll("\\s+", " ").trim();
        if (name.contains(",")) {
            return name;
        }
        int pos = name.lastIndexOf(' ');
        if (pos == -1) {
            return name;
        }
        return name.substring(pos + 1, name.length()) + ", " + name.substring(0, pos);
    }
}

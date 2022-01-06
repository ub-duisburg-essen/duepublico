package unidue.ub.duepublico.authorization;

import javax.inject.Singleton;

import org.mycore.access.strategies.MCRAccessCheckStrategy;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * For now, this strategy will only use the new FactsAccessSystem 
 * to check access to objects and derivates. 
 * For anything else, use the MIROwnerStrategy as fallback.  
 **/
@Singleton
public class UDEStrategy implements MCRAccessCheckStrategy {

    private static MCRAccessCheckStrategy rulesXML = MCRConfiguration2
        .getSingleInstanceOf("org.mycore.access.facts.MCRFactsAccessSystem", MCRAccessCheckStrategy.class)
        .orElseThrow();

    private static MCRAccessCheckStrategy mirOwner = MCRConfiguration2
        .getSingleInstanceOf("org.mycore.mir.authorization.MIROwnerStrategy", MCRAccessCheckStrategy.class)
        .orElseThrow();

    @Override
    public boolean checkPermission(String id, String permission) {
        MCRAccessCheckStrategy toUse = (id != null) && MCRObjectID.isValid(id) ? rulesXML : mirOwner;
        return toUse.checkPermission(id, permission);
    }
}

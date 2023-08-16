package unidue.ub.duepublico.authorization;

import org.mycore.access.facts.MCRFactsAccessSystem;
import org.mycore.access.strategies.MCRAccessCheckStrategy;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mir.authorization.MIROwnerStrategy;

import jakarta.inject.Singleton;

/**
 * For now, this strategy will only use the new FactsAccessSystem 
 * to check access to objects and derivates. 
 * For anything else, use the MIROwnerStrategy as fallback.  
 **/
@Singleton
public class UDEStrategy implements MCRAccessCheckStrategy {

    private static MCRFactsAccessSystem rulesXML = MCRConfiguration2
        .getSingleInstanceOf("org.mycore.access.facts.MCRFactsAccessSystem", MCRFactsAccessSystem.class)
        .orElseThrow();

    private static MIROwnerStrategy mirOwner = MCRConfiguration2
        .getSingleInstanceOf("org.mycore.mir.authorization.MIROwnerStrategy", MIROwnerStrategy.class)
        .orElseThrow();

    @Override
    public boolean checkPermission(String id, String permission) {
        MCRAccessCheckStrategy toUse = (id != null) && MCRObjectID.isValid(id) ? rulesXML : mirOwner;
        return toUse.checkPermission(id, permission);
    }
}

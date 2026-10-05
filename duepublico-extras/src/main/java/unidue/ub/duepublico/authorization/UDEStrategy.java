package unidue.ub.duepublico.authorization;

import jakarta.inject.Singleton;

import org.mycore.access.facts.MCRFactsAccessSystem;
import org.mycore.access.strategies.MCRAccessCheckStrategy;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mir.authorization.MIROwnerStrategy;

/**
 * For now, this strategy will only use the new FactsAccessSystem 
 * to check access to objects and derivates. 
 * For anything else, use the MIROwnerStrategy as fallback.  
 **/
@Singleton
public class UDEStrategy implements MCRAccessCheckStrategy {

    private static MCRFactsAccessSystem rulesXML = MCRConfiguration2
        .getSingleInstanceOf(MCRFactsAccessSystem.class, "org.mycore.access.facts.MCRFactsAccessSystem")
        .orElseThrow();

    private static MIROwnerStrategy mirOwner = MCRConfiguration2
        .getSingleInstanceOf(MIROwnerStrategy.class,"org.mycore.mir.authorization.MIROwnerStrategy")
        .orElseThrow();

    @Override
    public boolean checkPermission(String id, String permission) {
        MCRAccessCheckStrategy toUse = (id != null) && MCRObjectID.isValid(id) ? rulesXML : mirOwner;
        return toUse.checkPermission(id, permission);
    }
}

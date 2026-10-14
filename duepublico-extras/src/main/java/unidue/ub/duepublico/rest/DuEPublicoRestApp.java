package unidue.ub.duepublico.rest;

import jakarta.ws.rs.ApplicationPath;

import org.apache.logging.log4j.LogManager;
import org.glassfish.jersey.server.ResourceConfig;
import org.glassfish.jersey.server.ServerProperties;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.frontend.jersey.access.MCRRequestScopeACLFilter;
import org.mycore.restapi.MCRCORSResponseFilter;
import org.mycore.restapi.MCRIgnoreClientAbortInterceptor;
import org.mycore.restapi.MCRSessionFilter;
import org.mycore.restapi.MCRTransactionFilter;
import org.mycore.services.queuedjob.rest.MCRJobQueueFeature;

@ApplicationPath("/api/rest")
public class DuEPublicoRestApp extends ResourceConfig {

    /**
     * Creates the Jersey application for the DuEPublico-API
     */
    public DuEPublicoRestApp() {
        super();
        initAppName();
        property(ServerProperties.APPLICATION_NAME, getApplicationName());
        packages(getRestPackages());
        property(ServerProperties.RESPONSE_SET_STATUS_OVER_SEND_ERROR, true);
        register(MCRSessionFilter.class);
        register(MCRTransactionFilter.class);
        register(MCRJobQueueFeature.class);
        register(MCRCORSResponseFilter.class);
        register(MCRRequestScopeACLFilter.class);
        register(MCRIgnoreClientAbortInterceptor.class);
    }

    /**
     * Sets the application name for the Jersey application
     */
    protected void initAppName() {
        setApplicationName("DuEPublico-API " + getVersion());
        LogManager.getLogger().info("Initiialize {}", getApplicationName());
    }

    /**
     * @return the version of the DuEPublico-API
     */
    protected String getVersion() {
        return "1.0";
    }

    /**
     * @return the packages to scan for REST resources
     */
    protected String[] getRestPackages() {
        return MCRConfiguration2.getOrThrow("DuEPublico.API.Resource.Packages", MCRConfiguration2::splitValue)
            .toArray(String[]::new);
    }
}

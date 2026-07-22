package unidue.ub.duepublico.resources;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.core.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.config.MCRConfigurationException;
import org.mycore.common.content.MCRSourceContent;

@Path("export-list")
public class DuEPublicoPredefinedExportResource {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String DEFAULT_CONTENT_TYPE = "text/plain; charset=UTF-8";

    /**
     * Takes an id, resolves the corresponding configured URI and returns the requested content, or an error.
     * Syntax of configuration is:
     * <pre><code>DuEPublico.PredefinedExport.<id>.URI=<URI to resolve></code></pre>
     * @param id the id with which the configuration is defined
     * @return the response with the transformed content of the request or an error
     */
    @GET
    @Path("{id}")
    public Response predefinedExport(@PathParam("id") String id) {

        String solrURI;
        try {
            solrURI = MCRConfiguration2.getStringOrThrow("DuEPublico.PredefinedExport." + id + ".URI");
        } catch (MCRConfigurationException e) {
            return Response.status(Response.Status.NOT_FOUND).type(DEFAULT_CONTENT_TYPE).build();
        }
        LOGGER.info("Request is: {}", solrURI);
        try {
            MCRSourceContent content = MCRSourceContent.getInstance(solrURI);
            final String mimeType = content.getMimeType();
            byte[] data = content.getContentInputStream().readAllBytes();
            return Response.ok(data).type(mimeType != null && !mimeType.isBlank() ?
                                          mimeType : DEFAULT_CONTENT_TYPE).build();
        } catch (Exception e) {
            LOGGER.error("Could not create predefined export for id {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity("Could not create export: " + e.getMessage())
                .type(DEFAULT_CONTENT_TYPE)
                .build();
        }
    }

}

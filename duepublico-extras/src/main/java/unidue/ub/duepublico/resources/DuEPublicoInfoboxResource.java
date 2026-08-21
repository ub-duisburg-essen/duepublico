package unidue.ub.duepublico.resources;

import jakarta.ws.rs.DefaultValue;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.content.MCRSourceContent;

@Path("infobox")
public class DuEPublicoInfoboxResource {

    private static final Logger LOGGER = LogManager.getLogger();

    /**
     * Returns the infobox in PDF format for a given Duepublico-ID.
     * User needs to be authenticated as admin to gain access.
     * @param pageFormat an optional query-param for the page format. Possible values are: A4, A4-landscape, A5,
     *                   A5-landscape and A6-landscape. If not set, A6-landscape is used as default
     * @param duepublicoId the ID for which an infobox needs to be generated
     * @return the PDF with the infobox
     */
    @GET
    @Path("{duepublicoId}")
    public Response predefinedExport(@PathParam("duepublicoId") String duepublicoId,
        @QueryParam("PageFormat") @DefaultValue("") String pageFormat) {

        // TODO: Change to REST-API user once set up
        if (!MCRSessionMgr.getCurrentSession().getUserInformation().isUserInRole("admin")) {
            return Response.status(Response.Status.FORBIDDEN).build();
        }

        String infoboxURI = !pageFormat.isEmpty()
                            ? "xslTransform:mycoreobject-infobox?PageFormat=" + pageFormat + ":mcrobject:" + duepublicoId
                            : "xslTransform:mycoreobject-infobox:mcrobject:" + duepublicoId;

        LOGGER.info("Request is: {}", infoboxURI);
        try {
            MCRSourceContent content = MCRSourceContent.getInstance(infoboxURI);
            byte[] data = content.getContentInputStream().readAllBytes();
            return Response.ok(data).type("application/pdf").build();
        } catch (Exception e) {
            LOGGER.error("Could not create infobox export for id {}", duepublicoId, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity("Could not create export: " + e.getMessage())
                .build();
        }
    }

}

package unidue.ub.duepublico;

import java.io.IOException;
import java.io.InputStream;

import javax.xml.transform.TransformerException;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.InputStreamEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRSourceContent;
import org.mycore.common.content.MCRStreamContent;
import org.mycore.common.events.MCREvent;
import org.mycore.common.events.MCREventHandlerBase;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;

public class RedmineTicketHandler extends MCREventHandlerBase {

    private final static Logger LOGGER = LogManager.getLogger();

    private String buildURI;

    private String postURL;

    private String apiKey;

    public RedmineTicketHandler() {
        String prefix = "MCR.Redmine.";
        buildURI = MCRConfiguration.instance().getString(prefix + "TicketBuildURI");
        postURL = MCRConfiguration.instance().getString(prefix + "TicketPostURL");
        apiKey = MCRConfiguration.instance().getString(prefix + "APIKey");
    }

    @Override
    protected void handleObjectCreated(MCREvent evt, MCRObject obj) {
        String msg = " ticket in Redmine for ID " + obj.getId();

        try {
            MCRContent ticket = buildTicket(obj.getId()).getReusableCopy();
            LOGGER.debug(ticket.asString());

            if (ticket.asXML().getRootElement().getChildren().size() > 0) {
                ticket = createTicket(ticket).getReusableCopy();
                String id = ticket.asXML().getRootElement().getChildText("id");
                LOGGER.info("Created new" + msg + ", ticket ID = " + id);
            } else {
                LOGGER.info("Created no" + msg + ", ticket data empty");
            }
            LOGGER.debug(ticket.asString());
        } catch (Exception ex) {
            LOGGER.warn("Could not post new" + msg, ex);
        }
    }

    private MCRContent buildTicket(MCRObjectID oid) throws TransformerException {
        String uri = String.format(buildURI, oid.toString());
        return MCRSourceContent.getInstance(uri);
    }

    private MCRContent createTicket(MCRContent ticket) throws IOException, ClientProtocolException {
        String url = String.format(postURL, apiKey);
        HttpClient client = HttpClients.createDefault();
        HttpPost request = new HttpPost(url);

        InputStream requestBody = ticket.getInputStream();
        request.setEntity(new InputStreamEntity(requestBody, ContentType.TEXT_XML));
        requestBody.close();

        HttpResponse response = client.execute(request);
        return new MCRStreamContent(response.getEntity().getContent());
    }
}

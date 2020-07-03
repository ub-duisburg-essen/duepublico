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
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRSourceContent;
import org.mycore.common.content.MCRStreamContent;
import org.mycore.common.events.MCREvent;
import org.mycore.common.events.MCREventHandlerBase;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.xml.sax.SAXException;

public class RedmineTicketHandler extends MCREventHandlerBase {

    private final static Logger LOGGER = LogManager.getLogger();

    private String buildURI;

    private String postURL;

    private String queryURL;

    public RedmineTicketHandler() {
        String prefix = "MCR.Redmine.";

        String apiBaseURL = MCRConfiguration2.getString(prefix + "APIBaseURL").get();
        String apiKey = MCRConfiguration2.getString(prefix + "APIKey").get();
        String authorID = MCRConfiguration2.getString(prefix + "AuthorID").get();
        String customFieldOID = MCRConfiguration2.getString(prefix + "CustomField.ObjectID").get();

        postURL = String.format(apiBaseURL + "?key=%s", apiKey);
        queryURL = String.format(postURL + "&status_id=*&author_id=%s&cf_%s=", authorID, customFieldOID);
        buildURI = MCRConfiguration2.getString(prefix + "TicketBuildURI").get();
    }

    @Override
    protected void handleObjectCreated(MCREvent evt, MCRObject obj) {
        handleCreateTicket(obj, false);
    }

    @Override
    protected void handleObjectUpdated(MCREvent evt, MCRObject obj) {
        handleCreateTicket(obj, true);
    }

    @Override
    protected void handleObjectRepaired(MCREvent evt, MCRObject obj) {
        handleCreateTicket(obj, true);
    }

    private void handleCreateTicket(MCRObject obj, boolean update) {
        String msg = " ticket in Redmine for ID " + obj.getId();

        try {
            MCRContent ticket = buildTicket(obj.getId()).getReusableCopy();
            debug(ticket);

            if (!shouldBeCreated(ticket)) {
                LOGGER.info("Created no" + msg + ", ticket data empty");
                return;
            }

            if (update && ticketForThisObjectExists(obj.getId())) {
                LOGGER.info("Created no" + msg + ", ticket already exists");
                return;
            }

            ticket = createTicket(ticket).getReusableCopy();

            Element root = ticket.asXML().getRootElement();
            if ("ticket".equals(root.getName())) {
                String id = root.getChildText("id");
                LOGGER.info("Created new" + msg + ", ticket ID = " + id);
            } else {
                String error = root.getChildText("error");
                LOGGER.warn("Error posting new" + msg + ":" + error);
            }
            debug(ticket);

        } catch (Exception ex) {
            LOGGER.warn("Could not post new" + msg, ex);
        }
    }

    private MCRContent buildTicket(MCRObjectID oid) throws TransformerException {
        String uri = String.format(buildURI, oid.toString());
        return MCRSourceContent.getInstance(uri);
    }

    private void debug(MCRContent ticket) throws IOException {
        if (LOGGER.isDebugEnabled()) {
            LOGGER.debug(ticket.asString());
        }
    }

    private MCRContent createTicket(MCRContent ticket) throws IOException, ClientProtocolException {
        HttpClient client = HttpClients.createDefault();
        HttpPost request = new HttpPost(postURL);

        InputStream requestBody = ticket.getInputStream();
        request.setEntity(new InputStreamEntity(requestBody, ContentType.TEXT_XML));
        requestBody.close();

        HttpResponse response = client.execute(request);
        return new MCRStreamContent(response.getEntity().getContent());
    }

    private boolean shouldBeCreated(MCRContent ticket) throws JDOMException, IOException, SAXException {
        return ticket.asXML().getRootElement().getChildren().size() > 0;
    }

    private boolean ticketForThisObjectExists(MCRObjectID oid) {
        try {
            String url = queryURL + oid.toString();
            MCRContent xml = MCRSourceContent.getInstance(url);

            Element issues = xml.asXML().getRootElement();
            String totalCount = issues.getAttributeValue("total_count");

            return ("0".equals(totalCount) ? false : true);
        } catch (Exception ex) {
            String msg = "Could not check ticket in Redmine for ID " + oid;
            LOGGER.warn(msg, ex);
            return true;
        }
    }
}

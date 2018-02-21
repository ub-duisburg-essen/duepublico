package unidue.ub.duepublico;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Properties;

import javax.servlet.ServletException;

import org.mycore.common.MCRConstants;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.content.MCRByteContent;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;
import org.xml.sax.SAXException;
import org.apache.http.HttpEntity;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;

/**
 * Retrieves all thesis for a given year from university bibliography,
 * groups publications by top-level categories of the given classification
 * and outputs the grouped list as HTML or PDF.
 *
 * thesis-list-grouped.xsl does the HTML output.
 * thesis-list-grouped-pdf.xsl does the PDF output
 * Invoke ThesisListServiet?year=YYYY&by={ORIGIN|fachreferate}[&XSL.Style=pdf]
 *
 * @author Frank L\u00FCtzenkirchen
 */
public class ThesisListServlet extends MCRServlet {

    public static final long serialVersionUID = 7769435705880862646L;

    private MCRCategoryDAO dao = MCRCategoryDAOFactory.getInstance();

    /** URL to query university bibliography, configure via DuEPublico.ThesisList.UBOQuery.URL */
    private String uboQueryURL;

    /** Timeout in milliseconds to query university bibliography, configure via DuEPublico.ThesisList.UBOQuery.Timeout */
    private int uboQueryTimeout;

    /** The default classification to group by, if not given by request parameter */
    private String defaultClassification;

    private RequestConfig requestConfig;

    @Override
    public void init() throws ServletException {
        super.init();
        requestConfig = buildRequestConfig();

        MCRConfiguration config = MCRConfiguration.instance();
        this.uboQueryURL = config.getString("DuEPublico.ThesisList.UBOQuery.URL");
        this.uboQueryTimeout = config.getInt("DuEPublico.ThesisList.UBOQuery.Timeout", 10000);
        this.defaultClassification = config.getString("DuEPublico.ThesisList.DefaultClassification");
    }

    /** Builds HTTP Request configuration for remote call to university bibliography */
    private RequestConfig buildRequestConfig() {
        RequestConfig.Builder builder = RequestConfig.custom();
        builder.setConnectTimeout(uboQueryTimeout);
        builder.setSocketTimeout(uboQueryTimeout);
        builder.setConnectionRequestTimeout(uboQueryTimeout);
        return builder.build();
    }

    @Override
    protected void doGetPost(MCRServletJob job) throws Exception {
        String year = getYearToDisplay(job);
        String classificationID = getClassificationToGroupBy(job);

        List<Element> publications = getPublicationsFromUBO(year);
        LinkedHashMap<String, Element> groups = prepareGroups(classificationID);
        assignPublications2Groups(classificationID, publications, groups);

        Element thesisListGrouped = buildOutput(groups);
        thesisListGrouped.setAttribute("today", new SimpleDateFormat("dd.MM.yyyy").format(new Date()));
        thesisListGrouped.setAttribute("year", year);
        thesisListGrouped.setAttribute("by", classificationID);
        MCRContent output = new MCRJDOMContent(thesisListGrouped);

        MCRServlet.getLayoutService().doLayout(job.getRequest(), job.getResponse(), output);
    }

    private String getClassificationToGroupBy(MCRServletJob job) {
        String classificationID = job.getRequest().getParameter("by");
        if (classificationID == null || classificationID.isEmpty()) {
            classificationID = defaultClassification;
        }
        return classificationID;
    }

    /**
     * Returns the requested year given as request parameter.
     * If the year is not given, the year of the current date minus 31 days is used.
     * That means for example, display the list of 2018 if it's at least 1st Feb 2018.
     * In january, still display the "old" year.
     */
    private String getYearToDisplay(MCRServletJob job) {
        String year = job.getRequest().getParameter("year");
        if (year == null || year.isEmpty()) {
            LocalDateTime now = LocalDateTime.now();
            now = now.minusDays(31);
            year = String.valueOf(now.getYear());
        }
        return year;
    }

    /**
     * Queries the remote university bibliography for all thesis of the given year and returns them as mods:mods elements.
     *
     * @param year the year of promotion
     * @return list of mods:mods
     */
    private List<Element> getPublicationsFromUBO(String year)
        throws IOException, ClientProtocolException, JDOMException, SAXException {

        HttpGet request = new HttpGet(uboQueryURL + year);
        request.setConfig(requestConfig);

        CloseableHttpClient client = HttpClients.createDefault();
        CloseableHttpResponse response = client.execute(request);
        try {
            HttpEntity entity = response.getEntity();
            byte[] responseBody = EntityUtils.toByteArray(entity);
            Document xml = new MCRByteContent(responseBody).asXML();
            return xml.getRootElement().getChildren();
        } finally {
            response.close();
            client.close();
        }
    }

    /**
     * Reads the given classification and builds group elements for each top-level category.
     */
    private LinkedHashMap<String, Element> prepareGroups(String classificationID) {
        LinkedHashMap<String, Element> id2group = new LinkedHashMap<String, Element>();
        MCRCategoryID rootID = new MCRCategoryID(classificationID, null);
        for (MCRCategory category : dao.getChildren(rootID)) {
            Element group = new Element("group");
            group.setAttribute("label", category.getCurrentLabel().get().getText());
            id2group.put(category.getId().getID(), group);
        }
        return id2group;
    }

    /**
     * For each mods:mods publication element in the list, moves the publication as a child into its group.
     */
    private void assignPublications2Groups(String classificationID, List<Element> publications,
        LinkedHashMap<String, Element> groups) {

        for (Iterator<Element> iterator = publications.iterator(); iterator.hasNext();) {
            Element publication = iterator.next();
            iterator.remove();

            String groupID = getTargetGroupID(publication, classificationID);
            if (groupID == null) {
                continue;
            }
            Element group = groups.get(groupID);
            if (group == null) {
                continue;
            }
            group.addContent(publication.detach());
        }
    }

    /**
     * For the given mods:mods publication, returns the ID of the root category (first level of classification)
     * of the given classification, so we can decide into wich group this publication belongs
     */
    private String getTargetGroupID(Element publication, String classificationID) {
        String key = "DuEPublico.ThesisList.ClassificationMapping." + classificationID;
        String uboClassificationID = MCRConfiguration.instance().getString(key);

        for (Element classification : publication.getChildren("classification", MCRConstants.MODS_NAMESPACE)) {
            if (classification.getAttributeValue("authorityURI", "").contains(uboClassificationID)) {
                String valueURI = classification.getAttributeValue("valueURI");
                String categoryID = valueURI.split("#")[1];
                return getRootParentID(classificationID, categoryID);
            }
        }
        return null;
    }

    /**
     * Returns the ID of the root category (first level of classification) for the given child category ID somewhere below
     */
    private String getRootParentID(String classificationID, String categoryID) {
        MCRCategoryID childID = new MCRCategoryID(classificationID, categoryID);
        List<MCRCategory> parents = dao.getParents(childID);
        return parents.size() == 1 ? categoryID : parents.get(parents.size() - 2).getId().getID();
    }

    /**
     * Builds a new <thesis-list-grouped /> element containing only those groups that actually have publications
     */
    private Element buildOutput(LinkedHashMap<String, Element> id2group) {
        Element groups = new Element("thesis-list-grouped");
        for (Element group : id2group.values()) {
            if (!group.getChildren().isEmpty()) {
                groups.addContent(group);
            }
        }
        return groups;
    }
}

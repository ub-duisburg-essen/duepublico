package unidue.ub.duepublico.statistics.series;

import java.util.ArrayList;
import java.util.List;

import org.jdom2.Element;
import org.mycore.common.MCRConstants;
import org.mycore.common.events.MCRStartupHandler;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.frontend.MCRFrontendUtil;

public class SeriesStatisticsExporter {

    final static String BASE_URL = MCRFrontendUtil.getBaseURL();

    private final static String DOCUMENT_URL = BASE_URL + "receive/%s?XSL.Style=xml";

    private List<Publication> publications = new ArrayList<Publication>();

    public SeriesStatisticsExporter() {
        MCRStartupHandler.startUp(null);
    }

    public void fetchDocuments(String id, StatisticDates statisticDates)
        throws Exception {
        Element document = fetchDocumentMetadata(id);
        if (!"mycoreobject".equals(document.getName()))
            return;

        List<Element> childRelations = XPaths.xPaths.get("children").evaluate(document);
        if (childRelations.isEmpty()) {
            Statistics statistics = new Statistics(id, statisticDates);
            this.publications.add(new Publication(id, document, statistics));
        }
        for (Element relation : childRelations) {
            String childID = relation.getAttributeValue("href", MCRConstants.XLINK_NAMESPACE);
            fetchDocuments(childID, statisticDates);
        }
    }

    private static Element fetchDocumentMetadata(String id) throws Exception {
        System.out.println("Fetching document metadata of ID " + id);
        String url = String.format(DOCUMENT_URL, id);
        return MCRURIResolver.instance().resolve(url);
    }

    public List<Publication> getPublications() {
        return publications;
    }
}

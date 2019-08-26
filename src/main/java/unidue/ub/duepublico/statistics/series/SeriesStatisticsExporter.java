package unidue.ub.duepublico.statistics.series;

import java.util.ArrayList;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.common.MCRConstants;
import org.mycore.common.events.MCRStartupHandler;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.frontend.MCRFrontendUtil;

public class SeriesStatisticsExporter {

    final static String BASE_URL = MCRFrontendUtil.getBaseURL();

    private final static String DOCUMENT_URL = BASE_URL + "receive/%s?XSL.Style=xml";

    private List<Publication> publications = new ArrayList<Publication>();
    private final static Logger LOGGER = LogManager.getLogger(SeriesStatisticsExporter.class);

    public SeriesStatisticsExporter() {
    }

    public void saveAsExcel(String id, StatisticDates statisticDates, String target, String filename) throws Exception {

        MCRStartupHandler.startUp(null);
        fetchDocuments(id, statisticDates);
 
        Report report = new ExcelReport(this.publications, statisticDates, target, filename);
        report.save();
    }

    private void fetchDocuments(String id, StatisticDates statisticDates)
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
        LOGGER.info("Fetching document metadata of ID " + id);
        
        String url = String.format(DOCUMENT_URL, id);
        return MCRURIResolver.instance().resolve(url);
    }

    public List<Publication> getPublications() {
        return publications;
    }
}

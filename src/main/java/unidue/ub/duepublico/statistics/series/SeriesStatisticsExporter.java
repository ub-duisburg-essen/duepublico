package unidue.ub.duepublico.statistics.series;

import java.util.ArrayList;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.common.MCRConstants;
import org.mycore.common.xml.MCRURIResolver;

public class SeriesStatisticsExporter {

    final static String URI_PATTERN = "mcrobject:";

    private List<Publication> publications = new ArrayList<Publication>();
    private final static Logger LOGGER = LogManager.getLogger(SeriesStatisticsExporter.class);
    
    public SeriesStatisticsExporter() {
    }

    public void saveAsExcel(String id, StatisticDates statisticDates, String target, String filename) throws Exception {

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
        return MCRURIResolver.instance().resolve(URI_PATTERN + id);
    }

    public List<Publication> getPublications() {
        return publications;
    }
}

package unidue.ub.duepublico.statistics.series;

import org.mycore.common.events.MCRStartupHandler;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;

import java.util.ArrayList;
import java.util.List;

import org.jdom2.Element;
import org.mycore.common.MCRConstants;
import org.mycore.common.xml.MCRURIResolver;

/**
 * Provides commands for statistics 
 * 
 */
@MCRCommandGroup(name = "Statistic Commands")
public class StatisticsExportCommands {

    final static String BASE_URL = MCRFrontendUtil.getBaseURL();

    private final static String DOCUMENT_URL = BASE_URL + "receive/%s?XSL.Style=xml";

    //    private final static List<Publication> publications = new ArrayList<Publication>();

    /**
     * Exports series statistics in Excel XLSX File. 
     * Starts at the document with the base ID, which is the root of the series.
     * Traverses down to the child documents.
     * If a document does not have children, it is assumed to be a publication.
     * Reads access statistics from Statisticsservlet on this server for that document. 
     * 
     * @param documentID
     * @param directory
     * @param minYear
     * @param minMonth
     * @param maxYear
     * @param maxMonth
     * @throws Exception
     */
    @org.mycore.frontend.cli.annotation.MCRCommand(
        syntax = "Export series with document base ID {0} to directory {1} in mycore home data in timeperiod from year {2} in month {3} until year {4} in month {5}",
        help = "Example for ogesomo statistics in August 2019: Export series with document base ID duepublico_mods_00046595 to directory ogesomo_2019_statistics in mycore home data in timeperiod from year 2019 in month 8 until year 2019 in month 8",
        order = 10)
    public static void exportSeriesStatistics(String documentID, String directory, int minYear, int minMonth,
        int maxYear, int maxMonth) throws Exception {

        MCRStartupHandler.startUp(null);
        fetchDocuments(documentID);
        //        new ExcelReport(publications).save();
    }

    private static void fetchDocuments(String id) throws Exception {
        Element document = fetchDocumentMetadata(id);
        if (!"mycoreobject".equals(document.getName()))
            return;

        List<Element> childRelations = XPaths.xPaths.get("children").evaluate(document);
        if (childRelations.isEmpty()) {
            //            publications.add(new Publication(id, document));
        }
        for (Element relation : childRelations) {
            String childID = relation.getAttributeValue("href", MCRConstants.XLINK_NAMESPACE);
            fetchDocuments(childID);
        }
    }

    private static Element fetchDocumentMetadata(String id) throws Exception {
        System.out.println("Fetching document metadata of ID " + id);
        String url = String.format(DOCUMENT_URL, id);
        return MCRURIResolver.instance().resolve(url);
    }
}

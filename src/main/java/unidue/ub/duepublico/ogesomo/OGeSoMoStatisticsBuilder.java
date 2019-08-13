package unidue.ub.duepublico.ogesomo;

import java.util.ArrayList;
import java.util.List;

import org.jdom2.Element;
import org.mycore.common.MCRConstants;
import org.mycore.common.events.MCRStartupHandler;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;

/**
 * Builds access statistics for OGeSoMo project.
 * To be run as a local Java application.
 * Reads publication's metadata and access statistics from DuEPublico via HTTPS.
 *
 * Starts at the document with the base ID, which is the root of the series.
 * Traverses down to the child documents.
 * If a document does not have children, it is assumed to be a publication.
 * Reads access statistics from DuEPublico for that document.
 * Outputs all collected statistics as Excel XLSX file.
 *
 * @author Frank L\u00FCtzenkirchen
 */

@MCRCommandGroup(name = "OGeSoMo Commands")
public class OGeSoMoStatisticsBuilder {

    private final static String BASE_ID = "duepublico_mods_00046595";

    final static String DUEPUBLICO_BASE_URL = "https://duepublico2.uni-due.de/";

    private final static String DOCUMENT_URL = DUEPUBLICO_BASE_URL + "receive/%s?XSL.Style=xml";

    private final static List<Publication> publications = new ArrayList<Publication>();

    @org.mycore.frontend.cli.annotation.MCRCommand(syntax = "build ogesomo statistics",
        help = "Example: build ogesomo statistics",
        order = 10)
    public static void buildStatistics() throws Exception {
        MCRStartupHandler.startUp(null);
        fetchDocuments(BASE_ID);
        new ExcelReport(publications).save();
    }

    private static void fetchDocuments(String id) throws Exception {
        Element document = fetchDocumentMetadata(id);
        if (!"mycoreobject".equals(document.getName()))
            return;

        List<Element> childRelations = XPaths.xPaths.get("children").evaluate(document);
        if (childRelations.isEmpty()) {
            publications.add(new Publication(id, document));
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

package unidue.ub.duepublico.statistics;

import java.io.*;
import java.util.*;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import org.jdom2.Element;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.MCRAbstractCommands;
import org.mycore.frontend.cli.MCRObjectCommands;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;

/**
 * Collects statistical information about every document in a query result.
 * Implements the command "build statistics for months {0} to {1} file {2}"
 * Before invoking this command, use the command
 * "select objects with query ..." to search the document you wish to handle.
 *
 * @author Frank L\u00fctzenkirchen
 **/
@MCRCommandGroup(name = "Statistics Commands")
public class StatisticsCommand extends MCRAbstractCommands {

    private final static Logger LOGGER = LogManager.getLogger(StatisticsCommand.class);

    /**
     * Implements a command to collect usage statistics for a set of documents.
     *
     * @param from first month in range, YYYY-MM, e.g. 2008-01
     * @param to last month in range, YYYY-MM, e.g. 2008-07
     * @param filename file name to write statistics output to, will be an XML file
     * @throws Exception possibly a parsing or IO exception with AWStats log files
     */
    @org.mycore.frontend.cli.annotation.MCRCommand(syntax = "build statistics for months {0} to {1} file {2}",
        help = "Example: build statistics for months 2008-01 to 2008-07 file statistics.xml",
        order = 10)
    public static void buildStatistics(String from, String to, String filename) throws Exception {
        StatisticsBuilder builder = new StatisticsBuilder();
        builder.setFromMonth(new LoggedMonth(from));
        builder.setToMonth(new LoggedMonth(to));

        int numDocuments = addSelectedObjects(builder);
        if (numDocuments == 0) {
            LOGGER.info("No objects selected. Use the 'select objects with query' command first!");
        } else {
            builder.buildStatistics();

            LOGGER.info("Building output...");
            Element output = OutputBuilder.buildXML(builder);
            new MCRJDOMContent(output).sendTo(new File(filename));
        }
    }

    /**
     * Add all objects that have been selected by the last query command
     */
    private static int addSelectedObjects(StatisticsBuilder builder) throws Exception {
        List<String> objectIDs = MCRObjectCommands.getSelectedObjectIDs();
        for (String objectID : objectIDs) {
            MCRObjectID oid = MCRObjectID.getInstance(objectID);
            builder.addLoggedObject(new LoggedDocument(oid));
        }
        return objectIDs.size();
    }
}

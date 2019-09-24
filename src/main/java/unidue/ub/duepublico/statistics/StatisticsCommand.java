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

import unidue.ub.duepublico.statistics.series.ExcelReport;
import unidue.ub.duepublico.statistics.series.Report;
import unidue.ub.duepublico.statistics.series.SeriesStatisticsExporter;
import unidue.ub.duepublico.statistics.series.StatisticDates;

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
     * 
     * Exports series statistics in Excel XLSX File. 
     * Starts at the document with the base ID, which is the root of the series.
     * Traverses down to the child documents.
     * If a document does not have children, it is assumed to be a publication.
     * Reads access statistics from Statisticsservlet on this server for that document. 
     * 
     * @param documentID
     * @param target
     * @param from
     * @param to
     * @param filename
     * @throws Exception
     */
    @org.mycore.frontend.cli.annotation.MCRCommand(
        syntax = "Export series with baseid {0} to directory {1} for months {2} to {3} filename {4}",
        help = "Example for ogesomo statistics in August 2019 (Excel Export): Export series with baseid duepublico_mods_00046595 to directory /data/ogesomo_2019_statistics/ for months 2019-08 to 2019-08 filename OGeSoMo_DuEPublico_Statistics_August_2019.xlsx",
        order = 10)
    public static void exportSeriesStatistics(String documentID, String target, String from, String to,
        String filename) throws Exception {

        LoggedMonth minMonth = new LoggedMonth(from);
        LoggedMonth maxMonth = new LoggedMonth(to);

        StatisticDates statisticDates = new StatisticDates(minMonth.getYear(), minMonth.getMonth(), maxMonth.getYear(),
            maxMonth.getMonth());
        
        LOGGER.info("Create SeriesStatisticsExporter with Statistic date range: " + statisticDates.getRange());
        
        SeriesStatisticsExporter exporter = new SeriesStatisticsExporter();

        exporter.saveAsExcel(documentID, statisticDates, target, filename);
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

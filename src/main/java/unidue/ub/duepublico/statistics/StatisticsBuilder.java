package unidue.ub.duepublico.statistics;

import java.util.*;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;

/**
 * Collects statistical information about document accesses using AWStats data
 * files. Extracts number of accesses on the document, every derivate and their
 * files from the logs.
 *
 * Create a new StatisticsBuilder.
 * Set the month range to evaluate.
 * Add objects for which number of accesses should  be counted.
 * Start building statistical data.
 * Use the OutputBuilder to output the data as XML.
 *
 * @author Frank L\u00fctzenkirchen
 **/
public class StatisticsBuilder {

    /** The first month to be evaluated at this run. Default is the first month logged. */
    private LoggedMonth fromMonth = LoggedMonth.getMinimum();

    /** The last month to be evaluated at this run. Default is the month we had yesterday. */
    private LoggedMonth toMonth = LoggedMonth.getMaximum();

    /** The log files that have been evaluated when buildStatistcs() was called */
    private List<LogFile> evaluatedLogFiles = new ArrayList<LogFile>();

    /** The objects to collect the number of accesses for */
    private List<LoggedObject> loggedObjects = new ArrayList<LoggedObject>();

    private final static Logger LOGGER = LogManager.getLogger(StatisticsBuilder.class);

    /** Add an object thats accesses should be counted. */
    public void addLoggedObject(LoggedObject loggedObject) {
        loggedObjects.add(loggedObject);
    }

    /** Returns the objects to evaluate / that have been evaluated */
    public List<LoggedObject> getLoggedObjects() {
        return loggedObjects;
    }

    /** Sets the first month to be evaluated at this run. Default is the first month logged. */
    public void setFromMonth(LoggedMonth month) {
        if (!month.before(LoggedMonth.getMinimum())) {
            fromMonth = month;
        }
    }

    /** Sets the last month to be evaluated at this run. Default is the month we had yesterday. */
    public void setToMonth(LoggedMonth month) {
        if (!month.after(LoggedMonth.getMaximum())) {
            toMonth = month;
        }
    }

    /** Returns log files that have been evaluated when buildStatistcs() was called */
    public List<LogFile> getEvaluatedLogFiles() {
        return evaluatedLogFiles;
    }

    /**
     * Collects access counts from the logs, for the month range and the logged objects set.
     * Afterwards, use OutputBuilder.buildXML() to get an XML representation of the collected data.
     *
     * @see OutputBuilder#buildXML(StatisticsBuilder)
     */
    public void buildStatistics() throws Exception {
        if (toMonth.before(fromMonth)) {
            LoggedMonth.swapMonths(fromMonth, toMonth);
        }

        LOGGER.info(
            "Building statistics for " + loggedObjects.size() + " objects for months " + fromMonth + " to " + toMonth);

        // For each month between from and to, collect statistics
        for (LoggedMonth month = fromMonth; month.before(toMonth) || month.equals(toMonth); month = month.nextMonth()) {
            beginMonth(month);

            List<LogFile> logFiles = LogFileFactory.getLogFilesFor(month);
            for (LogFile logFile : logFiles) {
                collectStatistics(logFile);
            }
            evaluatedLogFiles.add(logFiles.get(logFiles.size() - 1)); // Only remember last one for output

            finishMonth(month);
        }

        LOGGER.info("Finished collecting statistics");
    }

    /** Evaluates the given log file and collects statistics for all logged objects */
    private void collectStatistics(LogFile logFile) throws Exception {
        for (String line; (line = logFile.nextLine()) != null;) {
            String[] parts = line.split(" ", 3);
            String url = parts[0];
            String count = parts[1];
            for (LoggedObject object : loggedObjects) {
                if (object.isHandled(url, count)) {
                    break;
                }
            }
        }
    }

    /** For all logged objects, indicate counting starts for the given month */
    private void beginMonth(LoggedMonth month) throws Exception {
        for (LoggedObject object : loggedObjects) {
            object.getCounter().beginMonth(month);
        }
    }

    /** For all logged objects, finish counting for the month currently evaluated */
    private void finishMonth(LoggedMonth month) throws Exception {
        for (LoggedObject object : loggedObjects) {
            object.getCounter().finishMonth();
        }
    }
}

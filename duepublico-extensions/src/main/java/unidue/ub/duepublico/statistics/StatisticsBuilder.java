/**
 * $Revision: 26101 $ 
 * $Date: 2013-02-07 09:09:50 +0100 (Do, 07 Feb 2013) $
 *
 * This file is part of the MILESS repository software.
 * Copyright (C) 2011 MILESS/MyCoRe developer team
 * See http://duepublico.uni-duisburg-essen.de/ and http://www.mycore.de/
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

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
        if (!month.before(LoggedMonth.getMinimum()))
            fromMonth = month;
    }

    /** Sets the last month to be evaluated at this run. Default is the month we had yesterday. */
    public void setToMonth(LoggedMonth month) {
        if (!month.after(LoggedMonth.getMaximum()))
            toMonth = month;
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
        if (toMonth.before(fromMonth))
            LoggedMonth.swapMonths(fromMonth, toMonth);

        LOGGER.info("Building statistics for " + loggedObjects.size() + " objects for months " + fromMonth + " to " + toMonth);

        // For each month between from and to, collect statistics
        for (LoggedMonth month = fromMonth; month.before(toMonth) || month.equals(toMonth); month = month.nextMonth()) {
            LogFile logFile = new LogFile(month);
            evaluatedLogFiles.add(logFile);

            beginMonth(month);
            collectStatistics(logFile);
            finishMonth(month);
        }

        LOGGER.info("Finished collecting statistics");
    }

    /** Evaluates the given log file and collects statistics for all logged objects */
    private void collectStatistics(LogFile logFile) throws Exception {
        for (String line; (line = logFile.nextLine()) != null;)
            for (LoggedObject object : loggedObjects)
                if (object.isHandled(line))
                    break;
    }

    /** For all logged objects, indicate counting starts for the given month */
    private void beginMonth(LoggedMonth month) throws Exception {
        for (LoggedObject object : loggedObjects)
            object.getCounter().beginMonth(month);
    }

    /** For all logged objects, finish counting for the month currently evaluated */
    private void finishMonth(LoggedMonth month) throws Exception {
        for (LoggedObject object : loggedObjects)
            object.getCounter().finishMonth();
    }
}

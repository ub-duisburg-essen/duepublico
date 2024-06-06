package unidue.ub.duepublico.statistics;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.mycore.common.config.MCRConfiguration2;

/**
 * Returns representations of AWStats data files containing monthly access logs.
 * The property <code>DuEPublico.StatisticsServlet.LogFilePattern</code>
 * specifies the file name pattern and location of those data files.
 * There may be more than one pattern, e.g.
 *
 * <code>
 *  DuEPublico.StatisticsServlet.LogFilePattern.1=%MCR.DataDir%/awstats/awstatsMMYYYY.miless.txt
 *  DuEPublico.StatisticsServlet.LogFilePattern.2=%MCR.DataDir%/awstats/awstatsMMYYYY.duepublico.txt
 * </code>
 *
 * @author Frank L\u00FCtzenkirchen
 */
public class LogFileFactory {

    private static final String CONFIG_LOGFILE = "DuEPublico.StatisticsServlet.LogFilePattern";

    private static List<String> LOG_FILE_PATTERNS = new ArrayList<String>();

    static {
        Map<String, String> cfg = MCRConfiguration2.getSubPropertiesMap(CONFIG_LOGFILE);

        List<String> keys = new ArrayList<String>(cfg.keySet());
        Collections.sort(keys); // Read configuration in a defined order

        for (String key : keys) {
            LOG_FILE_PATTERNS.add(cfg.get(key));
        }
    }

    static List<LogFile> getLogFilesFor(LoggedMonth month) throws IOException {
        List<LogFile> logFiles = new ArrayList<LogFile>();

        for (String pattern : LOG_FILE_PATTERNS) {
            LogFile logFile = new LogFile(month, pattern);
            if (logFile.exists()) {
                logFiles.add(logFile);
                logFile.init();
            }
        }
        return logFiles;
    }
}

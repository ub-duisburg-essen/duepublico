package unidue.ub.duepublico.statistics;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import org.mycore.common.config.MCRConfigurationException;

/**
 * Represents an AWStats data file containing monthly access logs.
 * The property <code>DuEPublico.StatisticsServlet.LogFilePattern</code>
 * specifies the file name pattern and location of those data files,
 *
 * @see LogFileFactory
 * @author Frank L\u00FCtzenkirchen
 */
public class LogFile {

    /** The month this log file belongs to */
    private LoggedMonth month;

    /** The path to the data file */
    private Path path;

    /** The reader to read the data from */
    private BufferedReader reader;

    /** The length of the data file */
    private int fileLength;

    /** The values stored in the GENERAL section */
    private Map<String, String> generalValues = new HashMap<String, String>();

    /** The names of those sections that contain access counts: DOWNLOADS and SIDER */
    private final static Set<String> COUNTED_SECTIONS = new HashSet<String>();

    /** The position in the data file where those sections start */
    private List<Integer> offsetsOfCountedSections = new ArrayList<Integer>();

    private final static Logger LOGGER = LogManager.getLogger(LogFile.class);

    static {
        // These sections contain number of accesses for each URL
        COUNTED_SECTIONS.add("DOWNLOADS");
        COUNTED_SECTIONS.add("SIDER");
    }

    /**
     * Opens a new AWStats data log file and reads some initial values from it
     *
     * @param month The month that log file belongs to.
     */
    LogFile(LoggedMonth month, String logFilePattern) throws IOException {
        this.month = month;
        this.path = buildPathToLogFile(logFilePattern);
    }

    boolean exists() {
        return Files.exists(path);
    }

    void init() throws IOException {
        LOGGER.info("Reading log file " + path.toString());

        openFile();
        readSectionOffsets();
        readGeneralValues();
        goToNextCountedSection();
    }

    /**
     * Returns the month this log file belongs to.
     */
    public LoggedMonth getMonth() {
        return month;
    }

    /**
     * Builds the file name of this log file.
     * The property <code>MIL.StatisticsServlet.LogFilePattern</code>
     * specifies the file name pattern and location of those data files, e.g.
     *
     * <code>
     * MIL.Statistics.LogFilePattern=/var/awstats/logs/awstats.foo.MMYYYY.txt
     * </code>
     *
     * @return the full path of the AWStats data file
     */
    private Path buildPathToLogFile(String logFilePattern) {
        String path = logFilePattern;
        path = path.replaceFirst("MM", month.getMonthString());
        path = path.replaceFirst("YYYY", month.getYearString());
        return Paths.get(path);
    }

    private void openFile() throws IOException {
        if (!Files.isReadable(path)) {
            throw new MCRConfigurationException("Log file " + path.toString() + " can not be read");
        }

        fileLength = (int) (Files.size(path));
        reader = new BufferedReader(new InputStreamReader(Files.newInputStream(path)), fileLength);
        reader.mark(fileLength);
    }

    /**
     * Positions the reader after the next line beginning with the given prefix.
     */
    private void findLineBeginningWith(String prefix) throws IOException {
        while (!reader.readLine().startsWith(prefix)) {
            ;
        }
    }

    /**
     * Reads the MAP section of the data file to find the offsets of those
     * sections that contain access counts.
     */
    private void readSectionOffsets() throws IOException {
        findLineBeginningWith("BEGIN_MAP");
        for (String line; !(line = reader.readLine()).startsWith("END_");) {
            String[] tokens = line.split(" ");
            String sectionName = tokens[0].substring(4);
            if (COUNTED_SECTIONS.contains(sectionName)) {
                int offset = Integer.parseInt(tokens[1]);
                LOGGER.debug("Offset for section " + sectionName + " is " + offset);
                offsetsOfCountedSections.add(offset);
            }
        }
    }

    /**
     * Reads the GENERAL section of the data file and stores the values in a map.
     */
    private void readGeneralValues() throws IOException {
        findLineBeginningWith("BEGIN_GENERAL");
        for (String line; !(line = reader.readLine()).startsWith("END_");) {
            String[] tokens = line.split(" ");
            generalValues.put(tokens[0], tokens[1]);
        }
    }

    /**
     * Returns the value of the given property from the GENERAL section of the data file
     *
     * @param name the property in the GENERAL section
     * @return the value of that property, or null
     */
    public String getValue(String name) {
        return generalValues.get(name);
    }

    /**
     * Positions the reader after the BEGIN line of the next section that contains
     * access counts.
     *
     * @throws IOException
     */
    private void goToNextCountedSection() throws IOException {
        int offset = offsetsOfCountedSections.remove(0);
        LOGGER.debug("Skipping to next counted section at offset " + offset);
        reader.reset();
        reader.mark(fileLength);
        reader.skip(offset);
        reader.readLine();
    }

    /**
     * Returns the next line containing access counts for URLs.
     * Automatically skips all other lines and switches to the next section
     * that contains access counts.
     *
     * @return a single data line containing URL and number of accesses of that URL, or null if all lines have been read
     */
    public String nextLine() throws IOException {
        String line = reader.readLine();
        if (line == null) {
            reader.close();
            return null;
        } else if (!line.startsWith("END_")) {
            return line;
        } else if (!offsetsOfCountedSections.isEmpty()) {
            goToNextCountedSection();
            return nextLine();
        } else {
            reader.close();
            return null;
        }
    }
}

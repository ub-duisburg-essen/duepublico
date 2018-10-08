/**
 * $Revision: 29353 $ 
 * $Date: 2014-03-18 11:00:48 +0100 (Di, 18 Mär 2014) $
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
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.config.MCRConfigurationException;

/**
 * Represents an AWStats data file containing monthly access logs.
 * The property <code>DuEPublico.StatisticsServlet.LogFilePattern</code>
 * specifies the file name pattern and location of those data files, e.g.
 * 
 * <code>
 *  DuEPublico.StatisticsServlet.LogFilePattern=C:\\miless2mir\\prod\\awstats\\awstatsMMYYYY.miless.txt
 * </code>  
 * 
 * @author Frank L\u00FCtzenkirchen
 */
public class LogFile {

    /** The month this log file belongs to */
    private LoggedMonth month;

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
    
    /** 
     * Config part
     */
    private static final String CONFIG_LOGFILE = "DuEPublico.StatisticsServlet.LogFilePattern";

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
    public LogFile(LoggedMonth month) throws IOException {
        this.month = month;

        String fileName = buildLogFileName();
        LOGGER.info("Reading log file " + fileName);

        openFile(fileName);
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
    private String buildLogFileName() {
        String fileName = MCRConfiguration.instance().getString(CONFIG_LOGFILE);
        fileName = fileName.replaceFirst("MM", month.getMonthString());
        fileName = fileName.replaceFirst("YYYY", month.getYearString());
        return fileName;
    }

    private void openFile(String fileName) throws IOException {
        Path path = Paths.get(fileName);
        ensureThat(Files.exists(path), "Log file " + fileName + " does not exist");
        ensureThat(Files.isReadable(path), "Log file " + fileName + " can not be read");
        fileLength = (int) (Files.size(path));
        reader = new BufferedReader(new InputStreamReader(Files.newInputStream(path)), fileLength);
        reader.mark(fileLength);
    }

    private void ensureThat(boolean conditionThatMustBeTrue, String messageToThrowOtherwise) {
        if (!conditionThatMustBeTrue)
            throw new MCRConfigurationException(messageToThrowOtherwise);
    }

    /**
     * Positions the reader after the next line beginning with the given prefix.
     */
    private void findLineBeginningWith(String prefix) throws IOException {
        while (!reader.readLine().startsWith(prefix))
            ;
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
		} else if (!line.startsWith("END_"))
			return line;
		else if (!offsetsOfCountedSections.isEmpty()) {
			goToNextCountedSection();
			return nextLine();
		} else {
			reader.close();
			return null;
		}
	}
}

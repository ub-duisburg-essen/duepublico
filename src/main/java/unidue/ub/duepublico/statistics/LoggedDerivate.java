/**
 * $Revision: 26103 $ 
 * $Date: 2013-02-07 09:25:19 +0100 (Do, 07 Feb 2013) $
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

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang.StringUtils;
import org.jdom2.Element;
import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * Represents a derivate for that access should be evaluated.
 * Dynamically adds the files as child objects that should also be logged,
 * whenever a file path is detected in the log line. 
 * 
 * @author Frank L\u00FCtzenkirchen
 */
public class LoggedDerivate extends LoggedObject {

    /** The ID of the derivate */
	private MCRObjectID derivateID;
    
	
	// Logged derivates based on supported access logs from miless
    /** The pattern that occurs in the URL if this derivate is accessed: "/Derivate-ID" */
    private String idPatternMiless;
    
    private String idPatternMir;
    private final static String PATH_MIR_DERIVATE = "/MCRFileNodeServlet/duepublico_derivate_";

    /**
     * Contained and logged files of this derivate, by file path 
     */
    private Map<String, LoggedFile> files = new HashMap<String, LoggedFile>();

    public LoggedDerivate(MCRObjectID derivateID) {
        
    	this.derivateID = derivateID;
        this.idPatternMiless = "/Derivate-" + derivateID.getNumberAsInteger();
        this.idPatternMir = PATH_MIR_DERIVATE + derivateID.getNumberAsString() + "/";
        
    }

    /** Returns the derivate ID */
    public MCRObjectID getDerivateId() {
        return this.derivateID;
    }

    @Override
    public void setAttributes(Element xml) {
        xml.setAttribute("type", "derivate");
        xml.setAttribute("id", String.valueOf(this.derivateID));
    }

    @Override
    public boolean isHandled(String line) {
        if (isLoggedBy(line)) {
            String path = getExtraPath(line);
            if (path.equals(".xml")) {
                counter.count(line);
                return true;
            } else {
                return getLoggedFile(path).isHandled(line);
            }
        }
        return false;
    }

    /** 
     * Returns the LoggedFile that is related to the given file path.
     * If not already existing, it is dynamically created as a child object.
     */
    public LoggedFile getLoggedFile(String path) {
        LoggedFile file = files.get(path);
        if (file == null)
            file = buildFile(path);
        return file;
    }

    /**
     * Creates a new LoggedFile that is related to the given file path,
     * and adds it to the child object
     */
    private LoggedFile buildFile(String path) {
        LoggedFile file = new LoggedFile(path);
        addChild(file);

        // The newly created file does not know which month currently is evaluated, so let it know
        LoggedMonth currentMonth = counter.getCurrentMonthCounter().getMonth();
        file.getCounter().beginMonth(currentMonth);

        files.put(path, file);
        return file;
    }

    /** Checks if access to this derivate is logged by the given line */
    private boolean isLoggedBy(String line) {

        int posMiless = line.indexOf(idPatternMiless);
        int posMir = line.indexOf(idPatternMir);

        if (posMiless == -1 && posMir == -1) {

            /*
             * Doesn't match pattern
             */
            return false;
        }

        if (posMiless != -1) {

            /*
             * check match on miless derivate
             */
            char charAfterID = line.charAt(posMiless + idPatternMiless.length());
            if ((charAfterID != '/') && (charAfterID != '.'))
                return false;

            charAfterID = line.charAt(posMiless + idPatternMiless.length() + 1);
            return charAfterID != ' ';
        }

        return posMir != -1;
    }

    /**
     * Returns that portion of the URL in the log line that is the relative path to a file 
     */
    private String getExtraPath(String line) {
        int posMiless = line.indexOf(idPatternMiless);

        if (posMiless != -1) {

            /*
             * get path info from miless awstats log line
             */
            int beginIndex = line.indexOf(idPatternMiless) + idPatternMiless.length();
            int endIndex = line.indexOf(" ", beginIndex);
            String path = line.substring(beginIndex, endIndex);

            // Remove query string, if present
            int pos = path.indexOf("?");
            if (pos >= 0)
                path = path.substring(0, pos);

            // Remove virtual paths
            pos = path.indexOf("/_virtual/");
            if (pos >= 0)
                path = path.substring(0, pos);

            // Remove trailing slashes
            while (path.endsWith("/"))
                path = path.substring(0, path.length() - 1);

            return path;

        } else {

            return "/" + StringUtils.substringBetween(line, idPatternMir, " ");
        }
    }
}

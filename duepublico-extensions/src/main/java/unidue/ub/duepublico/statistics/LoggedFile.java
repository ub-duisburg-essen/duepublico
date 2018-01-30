/**
 * $Revision: 26087 $ 
 * $Date: 2013-02-06 12:57:11 +0100 (Mi, 06 Feb 2013) $
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

import org.jdom2.Element;

/**
 * Represents a file for that access should be evaluated.
 * Files are dynamically added as children of logged derivates,
 * whenever a file path is detected in the log line.  
 * 
 * @author Frank L\u00FCtzenkirchen
 */
public class LoggedFile extends LoggedObject {

    /** The relative path to the file within the derivate */
    protected String path;

    public LoggedFile(String path) {
        this.path = path;
    }

    @Override
    public void setAttributes(Element xml) {
        xml.setAttribute("type", "file");
        xml.setAttribute("path", path);
    }

    @Override
    public boolean isHandled(String line) {
        counter.count(line);
        return true;
    }
}

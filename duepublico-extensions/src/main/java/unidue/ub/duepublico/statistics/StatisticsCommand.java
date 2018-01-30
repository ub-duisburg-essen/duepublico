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

import java.io.*;
import java.util.*;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import org.jdom2.Element;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.MCRAbstractCommands;
import org.mycore.frontend.cli.MCRCommand;
import org.mycore.frontend.cli.MCRObjectCommands;

/**
 * Collects statistical information about every document in a query result.
 * Implements the command "build statistics for months {0} to {1} file {2}"
 * Before invoking this command, use the command 
 * "select objects with query ..." to search the document you wish to handle.
 * 
 * @author Frank L\u00fctzenkirchen
 **/
public class StatisticsCommand extends MCRAbstractCommands {

    private final static Logger LOGGER = LogManager.getLogger(StatisticsCommand.class);

    public StatisticsCommand() {
        addCommand(new MCRCommand("build statistics for months {0} to {1} file {2}",
                "miless.statistics.StatisticsCommand.buildStatistics String String String",
                "Example: build statistics for months 2008-01 to 2008-07 file statistics.xml"));
    }

    /**
     * Implements a command to collect usage statistics for a set of documents.
     * 
     * @param from first month in range, YYYY-MM, e.g. 2008-01
     * @param to last month in range, YYYY-MM, e.g. 2008-07
     * @param filename file name to write statistics output to, will be an XML file
     * @throws Exception possibly a parsing or IO exception with AWStats log files
     */
    public static void buildStatistics(String from, String to, String filename) throws Exception {
        StatisticsBuilder builder = new StatisticsBuilder();
        builder.setFromMonth(new LoggedMonth(from));
        builder.setToMonth(new LoggedMonth(to));

        int numDocuments = addSelectedDocuments(builder);
        if (numDocuments == 0) {
            LOGGER.info("No documents selected. Use the 'select objects with query' command first!");
        } else {
            builder.buildStatistics();
            
            LOGGER.info("Building output...");
            Element output = OutputBuilder.buildXML(builder);
            new MCRJDOMContent(output).sendTo(new File(filename));
        }
    }

    /**
     * Add all documents that have been selected by the last query command
     */
    private static int addSelectedDocuments(StatisticsBuilder builder) throws Exception {
        List<String> objectIDs = MCRObjectCommands.getSelectedObjectIDs();
        
        // to do later
        
//        for (String objectID : objectIDs) {
//            int documentID = MCRObjectID.getInstance(objectID).getNumberAsInteger();
//            builder.addLoggedObject(new LoggedDocument(documentID));
//        }
		return objectIDs.size();
	}
}

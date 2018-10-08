/**
 * $Revision: 26099 $ 
 * $Date: 2013-02-06 15:57:48 +0100 (Mi, 06 Feb 2013) $
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

import java.util.List;
import java.util.concurrent.TimeUnit;

import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * Represents a document for that access should be evaluated. Automatically adds
 * the derivates as child objects that should also be logged.
 * 
 * @author Frank L\u00FCtzenkirchen
 */
public class LoggedDocument extends LoggedObject {

	private static final Logger LOGGER = LogManager.getLogger(LoggedDocument.class);

	/** The ID of the document */
	private MCRObjectID documentID;

	// Logged Documents based on supported access logs from miless
	/** This pattern contains standard document access in miless */
	private String idPatternMiless;

	/**
	 * When a log line contains this pattern, it is possibly a candidate for
	 * further investigation
	 */
	private final static String PATTERN_MILESS_DOCUMENT = "DocumentServlet";

	private final static String PATTERN_MIR_DOCUMENT = "/rsc/stat/duepublico_mods_";

	public LoggedDocument(MCRObjectID documentID) throws Exception {

		this.documentID = documentID;

		this.idPatternMiless = "id=" + documentID.getNumberAsInteger();

		/*
		 * get derivatives
		 */
		List<MCRObjectID> derivatesForDocument = MCRMetadataManager.getDerivateIds(documentID, 0,
				TimeUnit.MILLISECONDS);

		if (derivatesForDocument != null) {

			for (MCRObjectID derivateID : derivatesForDocument) {

				String debugDerivateId = "Looking for statistics of document " + this.documentID.getBase() + "_"
						+ this.documentID.getNumberAsString() + ": " + "Look into derivate id " + derivateID.getBase()
						+ "_" + derivateID.getNumberAsString();
				LOGGER.debug(debugDerivateId);

				addChild(new LoggedDerivate(derivateID));
			}

		}
	}

	@Override
	public void setAttributes(Element xml) {
		xml.setAttribute("type", "document");
		xml.setAttribute("id", String.valueOf(documentID));
	}

	@Override
	public boolean isHandled(String line) {
		if (isLoggedBy(line)) {
			counter.count(line);
			return true;
		}
		return handleChildren(line);
	}

	/** Checks if access to this document is logged by the given line */
	private boolean isLoggedBy(String line) {

		int posMilessPattern = line.indexOf(PATTERN_MILESS_DOCUMENT);
		int posMirPattern = line.indexOf(PATTERN_MIR_DOCUMENT);

		if (posMilessPattern == -1 && posMirPattern == -1) {

			/*
			 * Doesn't match pattern
			 */
			return false;
		}

		posMilessPattern = line.indexOf(idPatternMiless, posMilessPattern + PATTERN_MILESS_DOCUMENT.length());

		if (posMilessPattern != -1) {

			/*
			 * check match on miless document id
			 */
			String charBeforeID = line.substring(posMilessPattern - 1, posMilessPattern);
			String charAfterID = line.substring(posMilessPattern + idPatternMiless.length(),
					posMilessPattern + idPatternMiless.length() + 1);
			return "?&".contains(charBeforeID) && "& ".contains(charAfterID);
		}

		if (posMirPattern != -1) {

			String mirIdPart = StringUtils.substringBetween(line, PATTERN_MIR_DOCUMENT, ".css"); //

			/*
			 * check match on mir document id
			 */
			return mirIdPart.matches("\\d+") && (mirIdPart).equals(documentID.getNumberAsString());
		}

		return false;
	}
}

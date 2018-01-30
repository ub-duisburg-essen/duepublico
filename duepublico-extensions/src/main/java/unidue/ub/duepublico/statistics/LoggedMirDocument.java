package unidue.ub.duepublico.statistics;

import org.jdom2.Element;

public class LoggedMirDocument extends LoggedObject {

	/**
	 * The pattern that occurs in the URL if this document is accessed: The ID
	 * request parameter
	 */
	private String idPattern;

	public LoggedMirDocument(String mirDocumentID) throws Exception {

		this.idPattern = mirDocumentID;
	}

	@Override
	public boolean isHandled(String line) {
		if (isLoggedBy(line)) {
			counter.count(line);
			return true;
		}
		return handleChildren(line);
	}

	/**
	 * 
	 * /** When a log line contains this pattern, it is possibly a candidate for
	 * further investigation
	 * 
	 *
	 * Standard pattern on receiving documents
	 */
	private final static String PATTERN_DOCUMENT_SERVLET = "receive/mir_mods_";

	/**
	 * 
	 * Insert a pattern mechanism on receiving documents via alias (?)
	 * 
	 */

	/** Checks if access to this document is logged by the given line */
	private boolean isLoggedBy(String line) {

		/*
		 * check first if line is matching document servlet pattern
		 * 
		 * 
		 */
		int pos = line.indexOf(PATTERN_DOCUMENT_SERVLET);
		if (pos == -1)
			return false;
		pos = line.indexOf(idPattern, pos + PATTERN_DOCUMENT_SERVLET.length());
		if (pos == -1)
			return false;

		/*
		 * Example:
		 *
		 * 
		 * id is 203 line is /servlets/DocumentServlet?id=2036
		 *
		 * prevent counting wrong line
		 * 
		 */

		String charBeforeID = line.substring(pos - 1, pos);
		String charAfterID = line.substring(pos + idPattern.length(), pos + idPattern.length() + 1);
		return "?&".contains(charBeforeID) && "& ".contains(charAfterID);
	}

	@Override
	public void setAttributes(Element xml) {
		// TODO Auto-generated method stub

	}

}

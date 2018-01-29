package unidue.ub.duepublico;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.solr.client.solrj.SolrClient;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.HttpSolrClient.Builder;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.solr.MCRSolrUtils;

/**
 *
 *
 * The {@code AliasDispatcherServlet} is a resolving mechanism to use meaningful
 * names for IDs in mycore.
 *
 * @author Paul Rochowski
 */
public class AliasDispatcherServlet extends HttpServlet {

	private static final long serialVersionUID = -4222669908309310140L;
	private static Logger LOGGER = LogManager.getLogger();

	private static final String SERVER_URL = "MCR.Module-solr.ServerURL";

	// Solr Fieldnames
	private static final String OBJECT_ID = "id";
	private static final String DERIVATES_LIST = "derivates";
	private static final String DERIVATE_ID = "derivateID";
	private static final String FILENAME = "fileName";
	private static final String ALIAS = "alias";

	/**
	 * 
	 * Client which communicates with MyCoRe Solr Server
	 */
	private SolrClient client = new Builder(MCRConfiguration.instance().getString(SERVER_URL)).build();

	@Override
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		SolrDocumentList results = new SolrDocumentList();
		String path = request.getPathInfo();
		boolean isforwarded = false;

		if (path != null) {

			List<String> pathParts = new ArrayList<String>(Arrays.asList(path.split("/")));

			pathParts.removeIf(pathPart -> pathPart.isEmpty());

			if (!pathParts.isEmpty()) {

				LOGGER.debug("Try to resolve Alias with path: " + path);

				path = parsePath(path);
				/*
				 * Try to resolve path as an alias
				 */
				results = getMCRObjectsFromSolr(path);

				/*
				 * Use request dispatcher to forward alias URL to equal MyCoRe
				 * Object URL
				 */
				if (!results.isEmpty() && results.get(0) != null) {

					RequestDispatcher dispatcher = request.getServletContext()
							.getRequestDispatcher("/receive/" + results.get(0).getFieldValue(OBJECT_ID));

					dispatcher.forward(request, response);

					LOGGER.debug("Alias was found with Object id: " + results.get(0).getFieldValue(OBJECT_ID));

					isforwarded = true;
				}

				/*
				 * If MyCoRe Object wasn't found, check higher path
				 */
				if (pathParts.size() > 1 && !isforwarded) {

					String aliasPart = "/";

					for (int i = 0; i < pathParts.size() - 1; i++) {

						aliasPart = aliasPart + pathParts.get(i) + "/";
					}

					String possibleFilename = pathParts.get(pathParts.size() - 1);

					LOGGER.debug("Try to resolve file with filename: " + possibleFilename);
					LOGGER.debug("Looking for derivates in alias: " + aliasPart);

					/*
					 * try to resolve mycore object belongs to filename
					 */
					results = getMCRObjectsFromSolr(parsePath(aliasPart));

					if (!results.isEmpty()) {

						/*
						 * Inspect derivatives
						 */
						Collection<Object> derivateIds = results.get(0).getFieldValues(DERIVATES_LIST);

						String searchStr = StringUtils.join(derivateIds, " OR " + DERIVATE_ID + ":");

						try {
							SolrDocumentList derivates = resolveSolrDocuments(DERIVATE_ID + ":" + searchStr);

							if (derivates != null && !derivates.isEmpty()) {

								for (SolrDocument derivate : derivates) {

									LOGGER.debug("Looking in derivate " + derivate.toString() + " for filename: "
											+ possibleFilename);

									if (derivate.getFieldValue(FILENAME).equals(possibleFilename)) {

										RequestDispatcher dispatcher = request.getServletContext()
												.getRequestDispatcher("/servlets/MCRFileNodeServlet/"
														+ derivate.getFieldValue(DERIVATE_ID) + "/" + possibleFilename);

										dispatcher.forward(request, response);
										isforwarded = true;

										LOGGER.info("Derivate found");

									}
								}
							}

						} catch (SolrServerException e) {

							LOGGER.error(e.getMessage());
							LOGGER.error("Error in communication with solr server: " + e.getMessage());
						}

					}
				}

			}
		}

		// Error redirect
		if (!isforwarded) {

			response.sendError(HttpServletResponse.SC_NOT_FOUND, "Requested Alias was not found: " + path);
		}
	}

	/**
	 * 
	 * Helper method for resolve an alias in solr
	 * 
	 * @param aliasPart
	 *            alias part
	 * @return Documentlist associated with given alias from solr
	 */
	protected SolrDocumentList getMCRObjectsFromSolr(String aliasPart) {

		SolrDocumentList results = new SolrDocumentList();

		try {

			String searchStr = ALIAS + ":%filter%".replace("%filter%",
					aliasPart != null && !aliasPart.isEmpty() ? MCRSolrUtils.escapeSearchValue(aliasPart) : "*");

			results = resolveSolrDocuments(searchStr);

			if (results.size() > 1) {

				LOGGER.info("Multiple MCR Objects found for Alias " + aliasPart);
			}

		} catch (SolrServerException | IOException e) {

			LOGGER.error(e.getMessage());
			LOGGER.error("Error in communication with solr server: " + e.getMessage());
		}

		return results;
	}

	/**
	 * Parses additional chars to given path
	 * 
	 * @param path
	 *            searchpath
	 * @return path without additional chars
	 */
	private String parsePath(String path) {

		/*
		 * remove "/" character at beginning and end
		 */
		if (path.charAt(path.length() - 1) == '/') {

			path = StringUtils.chop(path);
		}

		return path.substring(1);
	}

	/**
	 * 
	 * Resolving Solr Documents with given searchStr
	 * 
	 *
	 * @param searchStr
	 *            search String for solr query
	 * @return if there is an indexing in solr, then get the resolved document
	 * @throws SolrServerException
	 * @throws IOException
	 */
	public SolrDocumentList resolveSolrDocuments(String searchStr) throws SolrServerException, IOException {

		SolrQuery query = new SolrQuery();

		query.setQuery(searchStr);
		query.setStart(0);

		QueryResponse response;
		response = client.query(query);

		return response.getResults();
	}
}
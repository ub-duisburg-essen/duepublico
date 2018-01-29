package unidue.ub.duepublico.alias;

import java.io.IOException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.solr.client.solrj.SolrClient;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;
import org.apache.solr.common.SolrInputDocument;
import org.apache.solr.client.solrj.impl.HttpSolrClient.Builder;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.solr.MCRSolrUtils;

public class UDESolrResolver {

	private static Logger LOGGER = LogManager.getLogger(UDESolrResolver.class);

	public static final String FLAG_TYPE_ALIAS = "alias";

	private static final String SERVER_URL = "MCR.Module-solr.ServerURL";

	/**
	 * 
	 * Client which communicates with MyCoRe Solr Server
	 */
	private final static SolrClient client = new Builder(MCRConfiguration.instance().getString(SERVER_URL)).build();

	/**
	 * 
	 * Resolve query data from solr
	 * 
	 * @return Documentlist associated with given alias from solr
	 */
	public static SolrDocumentList getMCRObjectsFromSolr(String solrField, String searchparam) {

		SolrDocumentList results = new SolrDocumentList();

		try {

			String searchStr = solrField + ":%filter%".replace("%filter%",
					searchparam != null && !searchparam.isEmpty() ? MCRSolrUtils.escapeSearchValue(searchparam) : "*");

			results = resolveSolrDocuments(searchStr);

		} catch (SolrServerException | IOException e) {

			LOGGER.error(e.getMessage());
			LOGGER.error("Error in communication with solr server: " + e.getMessage());
		}

		return results;
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
	private static SolrDocumentList resolveSolrDocuments(String searchStr) throws SolrServerException, IOException {

		SolrQuery query = new SolrQuery();

		query.setQuery(searchStr);
		query.setStart(0);

		QueryResponse response;
		response = client.query(query);

		return response.getResults();
	}
	
	public static void updateIndex(SolrInputDocument updateDocument) {

		try {
			
			client.add(updateDocument);
			client.commit();
			
		} catch (SolrServerException e) {
			
			LOGGER.error("SolrServerException while do operation with solr client.", e);;
			
		} catch (IOException e) {
			
			LOGGER.error("IOException while do operation with solr client.", e);;
		}
	}
	

	public static SolrInputDocument toSolrInputDocument( SolrDocument solrdocument )
	{
	          SolrInputDocument doc = new SolrInputDocument();
	          for( String name : solrdocument.getFieldNames() )
	         {
	              doc.addField( name, solrdocument.getFieldValue(name), 1.0f );
	         }
	         return doc;
	}
}
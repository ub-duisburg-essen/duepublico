package unidue.ub.duepublico.alias;

import java.util.ArrayList;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.solr.common.SolrDocumentList;
import org.apache.solr.common.SolrInputDocument;
import org.mycore.common.events.MCREvent;
import org.mycore.common.events.MCREventHandlerBase;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * 
 * @author Paul
 *
 *         This event handler sets the following duepublico service flags: alias
 * 
 */
public class AliasEventHandler extends MCREventHandlerBase {

	/**
	 * constant for alias
	 */
	public static final String FLAG_TYPE_ALIAS = "alias";

	private static final String OBJECT_ID = "id";

	private static Logger LOGGER = LogManager.getLogger(AliasEventHandler.class);

	@Override
	protected final void handleObjectCreated(MCREvent evt, MCRObject obj) {
		if (!obj.isImportMode()) {

			ArrayList<String> values = obj.getService().getFlags(FLAG_TYPE_ALIAS);

			/*
			 * If there isn't an alias entry in current mycore object, we don't
			 * need to handle alias
			 */
			if (!values.isEmpty()) {

				LOGGER.info("Create Object with aliaspart: " + values.get(0) + "(created mycore Object id: "
						+ obj.getId().toString() + ")");

				String generatedCurrentAlias = updatedAliasString(obj, values.get(0));

				LOGGER.info("Alias flag was updated from " + values.get(0) + "to " + generatedCurrentAlias);
			}
		}
	}

	@Override
	protected final void handleObjectUpdated(MCREvent evt, MCRObject obj) {
		if (!obj.isImportMode()) {

			ArrayList<String> values = obj.getService().getFlags(FLAG_TYPE_ALIAS);

			/*
			 * If there isn't an alias entry in current mycore object, we don't
			 * need to handle alias
			 */
			if (!values.isEmpty()) {

				/*
				 * update mechanism (current mycore object id is available)
				 */
				MCRObjectID currentId = obj.getId();
				String currentIdValue = currentId.toString();

				SolrDocumentList currentList = UDESolrResolver.getMCRObjectsFromSolr(OBJECT_ID, currentIdValue);
				String currentAliasFromSolr = (String) currentList.get(0).get(FLAG_TYPE_ALIAS);

				/*
				 * Only do, if there is in fact an update (Solr index and alias
				 * flag are not sync)
				 */
				if (currentAliasFromSolr != null && !currentAliasFromSolr.equals(values.get(0))) {

					LOGGER.info("Update Object with aliaspart: " + values.get(0) + "(update mycore Object id: "
							+ obj.getId().toString() + ")");

					String generatedCurrentAlias = updatedAliasString(obj, values.get(0));

					/*
					 * update example:
					 * 
					 * sozial.geschichte-online/19/2016
					 * sozial.geschichte-online/19/2016/rezensionen
					 * 
					 * We have modified 19/2016 Alias into 19-2016. All follow
					 * mycore Objects must be updated
					 * 
					 * sozial.geschichte-online/19-2016 (generatedCurrentAlias)
					 * sozial.geschichte-online/19-2016/rezensionen
					 * 
					 */
					if (generatedCurrentAlias != null) {

						handleAliasUpdate(currentAliasFromSolr, generatedCurrentAlias);
					}
				}

			}
		}
	}

	public void handleAliasUpdate(String currentAliasFromSolr, String generatedCurrentAlias) {

		String paramWithWildcard = currentAliasFromSolr + "/*";

		/*
		 * get document list of follow solr documents connected with current
		 * Alias from Solr.
		 */
		SolrDocumentList documentsToAlias = UDESolrResolver.getMCRObjectsFromSolr(FLAG_TYPE_ALIAS, paramWithWildcard);

		LOGGER.info("Found " + documentsToAlias.getNumFound() + " mycore Objects with aliascontext "
				+ generatedCurrentAlias);

		/*
		 * get solr documentids to delete
		 */
		documentsToAlias.forEach((solrdocument) -> {

			String updatedAlias = ((String) solrdocument.getFieldValue(FLAG_TYPE_ALIAS)).replace(currentAliasFromSolr,
					generatedCurrentAlias);

			LOGGER.info("Update mycore Object " + solrdocument.getFieldValue(OBJECT_ID) + "." + "Update alias to "
					+ updatedAlias);

			solrdocument.setField(FLAG_TYPE_ALIAS, updatedAlias);

			MCRObjectID objectid = MCRObjectID.getInstance((String) solrdocument.getFieldValue(OBJECT_ID));
			MCRObject mcrobject = MCRMetadataManager.retrieveMCRObject(objectid);

			SolrInputDocument inputdoc = UDESolrResolver.toSolrInputDocument(solrdocument);
			UDESolrResolver.updateIndex(inputdoc);

			mcrobject.getService().removeFlags(FLAG_TYPE_ALIAS);
			mcrobject.getService().addFlag(FLAG_TYPE_ALIAS, updatedAlias);

			try {

				MCRMetadataManager.update(mcrobject);
			} catch (Exception e) {

				LOGGER.error("Failed to update mycore Object: " + solrdocument.getFieldValue(OBJECT_ID));
			}
		});
	}

	private String updatedAliasString(MCRObject obj, String aliasflag) {

		LOGGER.info("Looking for whole alias context of setted aliaspart: " + aliasflag);

		String generatedCurrentAlias = aliasflag;

		MCRObjectID parentId = obj.getParent();

		if (parentId != null) {

			String parentIdValue = parentId.toString();

			/*
			 * get through parent full alias context!
			 */
			SolrDocumentList parentList = UDESolrResolver.getMCRObjectsFromSolr(OBJECT_ID, parentIdValue);

			/*
			 * Thread conflict
			 * 
			 * There is a parent Id, but we can't resolve the associated solr
			 * document -> Thread sleep
			 */
			if (parentList.isEmpty()) {

				try {

					LOGGER.warn("Thread Conflict, get Solr Index for mycore Object: " + parentIdValue);

					Thread.sleep(1000);
				} catch (InterruptedException e) {

					LOGGER.error("Error in handling Alias", e);
				}

				parentList = UDESolrResolver.getMCRObjectsFromSolr(OBJECT_ID, parentIdValue);
			}

			String parentalias = (String) parentList.get(0).get(FLAG_TYPE_ALIAS);

			/*
			 * Not scheduled, the parent of current Object with Alias context
			 * should have also an alias.
			 */
			if (parentalias != null) {

				generatedCurrentAlias = parentalias + "/" + aliasflag;

			}
		}

		LOGGER.info("Full alias context was found: " + generatedCurrentAlias + "" + ". Parent mycoreobject is: "
				+ parentId);

		obj.getService().removeFlags(FLAG_TYPE_ALIAS);
		obj.getService().addFlag(FLAG_TYPE_ALIAS, generatedCurrentAlias);

		return generatedCurrentAlias;
	}
}
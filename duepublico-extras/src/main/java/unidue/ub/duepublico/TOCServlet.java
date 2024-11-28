package unidue.ub.duepublico;

import java.net.URLEncoder;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;

import org.jdom2.Element;
import org.mycore.common.MCRConstants;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.content.transformer.MCRXSLTransformer;
import org.mycore.common.xml.MCRLayoutService;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.common.xsl.MCRParameterCollector;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;

@WebServlet(name = "TOCServlet", urlPatterns = { "/servlets/TOCServlet" })
public class TOCServlet extends MCRServlet {

    @Override
    protected void doGetPost(MCRServletJob job) throws Exception {
        GroupingLevel root = new GroupingLevel();
        SortLevel current = root;

        HttpServletRequest req = job.getRequest();
        String field = req.getParameter("field");
        String id = req.getParameter("id");

        if (req.getParameter("groupBy") != null)
            for (String groupBy : req.getParameterValues("groupBy")) {
                String[] tokens = groupBy.split(" ");
                String fieldName = tokens[0];
                String sortOrder = tokens[1];
                String expanded = tokens[2];
                current = new GroupingLevel(fieldName, sortOrder, expanded, current);
            }

        if (req.getParameter("sortBy") != null)
            for (String sortBy : req.getParameterValues("sortBy")) {
                String[] tokens = sortBy.split(" ");
                String fieldName = tokens[0];
                String sortOrder = tokens[1];
                current = new SortLevel(fieldName, sortOrder, current);
            }

        String sort = URLEncoder.encode(root.asSortParam(), "UTF-8");

        JsonObject facets = root.toJson();

        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        System.out.println(gson.toJson(facets));

        String jsonFacet = URLEncoder.encode(facets.toString(), "UTF-8");

        String max = MCRConfiguration2.getString("MIR.TableOfContents.MaxResults").orElse("1000");
        String fl = MCRConfiguration2.getString("MIR.TableOfContents.FieldsUsed").orElse("*");
        String uri = String.format("solr:q=%s:%s&fl=%s&rows=%s&sort=%s&json.facet=%s", field, id, fl, max, sort, jsonFacet);

        MCRContent resonseFromSOLR = new MCRJDOMContent(MCRURIResolver.instance().resolve(uri));

        String[] stylesheets = { "xsl/toc/solr-facets2toc.xsl", "xsl/toc/render-toc.xsl" };
        MCRXSLTransformer solr2toc = MCRXSLTransformer.getInstance(stylesheets);
        MCRParameterCollector params = new MCRParameterCollector(req);
        MCRContent renderedTOC = solr2toc.transform(resonseFromSOLR, params);

        Element webPage = new Element("MyCoReWebPage");
        Element section = new Element("section");
        section.setAttribute("lang", "all", MCRConstants.XML_NAMESPACE);
        section.setAttribute("title", "TOC Layout Tester");
        webPage.addContent(section);
        section.addContent(renderedTOC.asXML().detachRootElement());
        MCRContent output = new MCRJDOMContent(webPage);

        //job.getRequest().setAttribute("XSL.Style", "xml");
        MCRLayoutService.instance().doLayout(job.getRequest(), job.getResponse(), output);
    }
}

class SortLevel {

    protected String fieldName;

    protected String sortOrder;

    protected SortLevel below;

    protected SortLevel() {
    }

    public SortLevel(String field, String order, SortLevel parent) {
        this.fieldName = field;
        this.sortOrder = order;
        parent.below = this;
    }

    public String asSortParam() {
        if (fieldName == null) {
            return (below == null ? "" : below.asSortParam());
        } else {
            String sort = fieldName + " " + sortOrder;
            return sort + (below == null ? "" : ", " + below.asSortParam());
        }
    }
}

class GroupingLevel extends SortLevel {

    private static final int MAX_FACETS_LEVEL = 100;

    private static final int MAX_FACETS_DOCS = 1000;

    private String expanded;

    public GroupingLevel() {
        super();
    }

    public GroupingLevel(String field, String order, String expanded, SortLevel parent) {
        super(field, order, parent);
        this.expanded = expanded;
    }

    public boolean hasNestedGroupingLevel() {
        return (below != null) && (below instanceof GroupingLevel);
    }

    public JsonObject toJson() {
        JsonObject facetDocs = new JsonObject();
        facetDocs.addProperty("type", "terms");
        facetDocs.addProperty("field", "id");
        facetDocs.addProperty("limit", MAX_FACETS_DOCS);

        if (hasNestedGroupingLevel()) {
            JsonObject filter = new JsonObject();
            filter.addProperty("filter", ((GroupingLevel) below).asFilter());
            facetDocs.add("domain", filter);
        }

        JsonObject facets = (hasNestedGroupingLevel() ? ((GroupingLevel) below).toJSONFacetQuery() : new JsonObject());
        facets.add("docs", facetDocs);

        return facets;
    }

    public JsonObject toJSONFacetQuery() {
        JsonObject facetParams = new JsonObject();
        facetParams.addProperty("type", "terms");
        facetParams.addProperty("limit", MAX_FACETS_LEVEL);
        facetParams.addProperty("field", fieldName);

        JsonObject sort = new JsonObject();
        sort.addProperty("index", sortOrder);
        facetParams.add("sort", sort);

        JsonObject subFacets = toJson();
        facetParams.add("facet", subFacets);

        JsonObject facet = new JsonObject();
        String facetName = fieldName + "_expanded_" + expanded;
        facet.add(facetName, facetParams);

        return facet;
    }

    public String asFilter() {
        String filter = "-" + fieldName + ":[* TO *]";
        return filter + (hasNestedGroupingLevel() ? " AND " + ((GroupingLevel) below).asFilter() : "");
    }
}

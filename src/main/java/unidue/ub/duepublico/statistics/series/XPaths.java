package unidue.ub.duepublico.statistics.series;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jdom2.Element;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.mycore.common.MCRConstants;

class XPaths {

    static Map<String, XPathExpression<Element>> xPaths = new HashMap<String, XPathExpression<Element>>();

    static {
        prepareXPath("children", "structure/children/child");
        prepareXPath("derobjects", "structure/derobjects/derobject");
        prepareXPath("servstates", "service/servstates/servstate");
        prepareXPath("id", "result/doc[1]/str[@name='id']");
        prepareXPath("publisher", "metadata//mods:mods/mods:originInfo[1]/mods:publisher[1]");
        prepareXPath("year", "metadata//mods:mods/mods:originInfo[1]/mods:dateIssued[1]");
        prepareXPath("title", "metadata//mods:mods/mods:titleInfo[1]/mods:title");
        prepareXPath("author", "metadata//mods:mods/mods:name[@type='personal']/mods:namePart[@type='family']");
        prepareXPath("doi", "metadata//mods:mods/mods:identifier[@type='doi'][1]");
        prepareXPath("isbn", "metadata//mods:mods/mods:identifier[@type='isbn']");
    }

    private static void prepareXPath(String alias, String xPath) {
        XPathExpression<Element> xpe = XPathFactory.instance().compile(xPath, Filters.element(), null,
            MCRConstants.MODS_NAMESPACE);
        xPaths.put(alias, xpe);
    }

    static String get(Element xml, String field, String delimiter, String defaultValue) {
        StringBuffer buffer = new StringBuffer();
        List<Element> elements = XPaths.xPaths.get(field).evaluate(xml);
        for (int i = 0; i < elements.size(); i++) {
            if (i > 0) {
                buffer.append(delimiter);
            }
            buffer.append(elements.get(i).getTextTrim());
        }
        return buffer.toString();
    }
}

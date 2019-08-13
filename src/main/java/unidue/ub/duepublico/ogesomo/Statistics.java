package unidue.ub.duepublico.ogesomo;

import org.jdom2.Element;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathFactory;
import org.mycore.common.xml.MCRURIResolver;

class Statistics {

    private final static String URL = OGeSoMoStatisticsBuilder.DUEPUBLICO_BASE_URL
        + "servlets/StatisticsServlet?id=%s&fromYear=%d&fromMonth=%d&toYear=%d&toMonth=%d&XSL.Style=xml";

    private final static String XPATH_DOWNLOADS = "object/object/object[@type='file']/num[@year='%s'][@month='%02d']";

    private final static String XPATH_LANDING_PAGE = "object[@type='document']/num[@year='%s'][@month='%02d']";

    static final int PDF_DOWNLOADS = 0;

    static final int LANDING_PAGE = 1;

    static int minYear = 2018;

    static int minMonth = 5;

    static int maxYear = 2018;

    static int maxMonth = 9;

    Element statistics;

    static String getRange() {
        return minMonth + "/" + minYear + "-" + maxMonth + "/" + maxYear;
    }

    static int getMinMonth(int year) {
        return year == minYear ? minMonth : 1;
    }

    static int getMaxMonth(int year) {
        return year == maxYear ? maxMonth : 12;
    }

    Statistics(String id) throws Exception {
        System.out.println("Fetching statistics of ID " + id);
        String url = String.format(URL, id, minYear, minMonth, maxYear, maxMonth);
        this.statistics = MCRURIResolver.instance().resolve(url);
    }

    int getNumAccess(int statisticsType, int year, int month) {
        int num = 0;
        String xPath = String.format(statisticsType == PDF_DOWNLOADS ? XPATH_DOWNLOADS : XPATH_LANDING_PAGE, year,
            month);
        for (Element stat : XPathFactory.instance().compile(xPath, Filters.element()).evaluate(statistics)) {
            num += Integer.parseInt(stat.getTextTrim());
        }
        return num;
    }
}

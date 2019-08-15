package unidue.ub.duepublico.statistics.series;

import org.jdom2.Element;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathFactory;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.frontend.MCRFrontendUtil;

class Statistics {

    private final static String URL = MCRFrontendUtil.getBaseURL()
        + "servlets/StatisticsServlet?id=%s&fromYear=%d&fromMonth=%d&toYear=%d&toMonth=%d&XSL.Style=xml";

    private final static String XPATH_DOWNLOADS = "object/object/object[@type='file']/num[@year='%s'][@month='%02d']";

    private final static String XPATH_LANDING_PAGE = "object[@type='document']/num[@year='%s'][@month='%02d']";

    static final int PDF_DOWNLOADS = 0;

    static final int LANDING_PAGE = 1;

    private int minYear;

    private int minMonth;

    private int maxYear;

    private int maxMonth;

    Element statistics;

    String getRange() {
        return this.minMonth + "/" + this.minYear + "-" + this.maxMonth + "/" + this.maxYear;
    }

    int getMinMonth(int year) {
        return year == this.minYear ? this.minMonth : 1;
    }

    int getMaxMonth(int year) {
        return year == this.maxYear ? this.maxMonth : 12;
    }

    Statistics(String id, int minYear, int minMonth, int maxYear, int maxMonth) throws Exception {
        System.out.println("Fetching statistics of ID " + id);
        this.minYear = minYear;
        this.minMonth = minMonth;
        this.maxMonth = maxMonth;
        this.maxYear = maxYear;

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

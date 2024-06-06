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

    Element statistics;

    Statistics(String id, StatisticDates statisticDates) throws Exception {
        System.out.println("Fetching statistics of ID " + id);
        String url = String.format(URL, id, statisticDates.getMinYear(),
            statisticDates.getMinMonth(), statisticDates.getMaxYear(), statisticDates.getMaxMonth());

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
package unidue.ub.duepublico.statistics;

import javax.servlet.annotation.WebServlet;

/**
 * $Revision: 26101 $
 * $Date: 2013-02-07 09:09:50 +0100 (Do, 07 Feb 2013) $
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

import javax.servlet.http.*;

import org.jdom2.Element;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;

/**
 * Outputs statistical information about document accesses using AWStats data files.
 * Invoke using the following request parameters (all numerical):
 *
 * id the ID of the document to display access statistics for.
 *
 * fromYear, fromMonth = first month to evaluate
 * toYear, toMonth = last month to evaluate
 * year, month = alternatively, evaluate a single month
 *
 * Year and month parameters may be skipped at all, then by default the last
 * six months are outputted.
 *
 * The output is rendered using statistics.xsl.
 *
 * @author Frank L\u00FCtzenkirchen
 **/
@WebServlet(name = "StatisticsServlet", urlPatterns = { "/servlets/StatisticsServlet/*" })
public class StatisticsServlet extends MCRServlet {

    /**
     *
     */
    private static final long serialVersionUID = 1L;

    /** When no interval is given, the default from date is target values months before the current date. */

    private static final int DEFAULT_FROM_MONTH_ADDITION = -5;

    private static final String CONFIG_ID_PREFIX = "MIR.projectid.default";

    public void doGetPost(MCRServletJob job) throws Exception {
        HttpServletRequest req = job.getRequest();
        HttpServletResponse res = job.getResponse();

        // First option: Invoke with fromYear,fromMonth - toYear,toMonth
        LoggedMonth fromMonth = getFromRequest(req, "fromYear", "fromMonth");
        LoggedMonth toMonth = getFromRequest(req, "toYear", "toMonth");

        // Second option: Invoke with single year,month
        LoggedMonth singleMonth = getFromRequest(req, "year", "month");

        // Third option: No year/month given uses current year/month
        LoggedMonth currentMonth = LoggedMonth.getMaximum();
        if (singleMonth == null) {
            singleMonth = currentMonth;
        }

        if (fromMonth == null) {
            fromMonth = singleMonth.addMonths(DEFAULT_FROM_MONTH_ADDITION);
        }
        if (toMonth == null) {
            toMonth = singleMonth;
        }

        StatisticsBuilder builder = new StatisticsBuilder();
        builder.setFromMonth(fromMonth);
        builder.setToMonth(toMonth);

        /*
         * parse url
         */
        String idPart = req.getPathInfo().replaceFirst("/", "");

        /*
         * look for correct id pattern (CONFIG_ID_PREFIX)
         */
        MCRObjectID mcrObjectId = MCRObjectID.getInstance(idPart);

        builder.addLoggedObject(new LoggedDocument(mcrObjectId));

        builder.buildStatistics();
        Element statistics = OutputBuilder.buildXML(builder);
        statistics.setAttribute("updatable", "true");

        getLayoutService().doLayout(req, res, new MCRJDOMContent(statistics));
    }

    private LoggedMonth getFromRequest(HttpServletRequest req, String paramYear, String paramMonth) {
        int year = getIntParameter(req, paramYear);
        int month = getIntParameter(req, paramMonth);
        return (year == 0 ? null : new LoggedMonth(year, month));
    }

    private int getIntParameter(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return (value == null ? 0 : Integer.parseInt(value));
    }

}

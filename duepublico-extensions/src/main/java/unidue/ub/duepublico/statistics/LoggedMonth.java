/**
 * $Revision: 29353 $ 
 * $Date: 2014-03-18 11:00:48 +0100 (Di, 18 Mär 2014) $
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

package unidue.ub.duepublico.statistics;

import java.util.Calendar;
import java.util.GregorianCalendar;

import org.mycore.common.config.MCRConfiguration;

/**
 * Represents a month when collecting statistics from the logs.
 * The allowed range for those months is specified by
 * 
 * <code>
 * MIL.StatisticsServlet.MinYear
 * MIL.StatisticsServlet.MinMonth
 * </code>
 * 
 * @author Frank L\u00FCtzenkirchen
 */
public class LoggedMonth {

    /** Internal representation of this month. Only year and month fields are used */
    private GregorianCalendar cal;
    
    /** 
     * Config part
     */
    private static final String CONFIG_MINYEAR = "UDE.StatisticsServlet.MinYear";
    private static final String CONFIG_MINMONTH = "UDE.StatisticsServlet.MinMonth";
    

    /** Creates a representation of the current month */
    public LoggedMonth() {
        this(new GregorianCalendar());
    }

    /** Creates a representation of the month of the given date */
    public LoggedMonth(GregorianCalendar cal) {
        this.cal = cal;
        cal.set(Calendar.DAY_OF_MONTH, 1);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
    }

    /**
     * Creates a new month.
     * 
     * @param year the year, as four-digit YYYY
     * @param month the month number, between 1 and 12 
     */
    public LoggedMonth(int year, int month) {
        this();
        setTo(year, month);
    }

    /**
     * Creates a new month from input string YYYY-MM
     * 
     * @param s the month, using syntax YYYY-MM
     */
    public LoggedMonth(String s) {
        this();
        String[] tokens = s.split("-");
        int year = Integer.parseInt(tokens[0]);
        int month = Integer.parseInt(tokens[1]);
        setTo(year, month);
    }

    /**
     * Sets the month to the given values.
     * 
     * @param year the year, as four-digit YYYY
     * @param month the month number, between 1 and 12 
     */
    public void setTo(int year, int month) {
        cal.set(Calendar.YEAR, year);
        cal.set(Calendar.MONTH, month - 1);
    }

    /**
     * Returns the year, as four-digit YYYY
     */
    public int getYear() {
        return cal.get(Calendar.YEAR);
    }

    /**
     * Returns the year as a String of length 4.
     */
    public String getYearString() {
        return String.valueOf(getYear());
    }

    /**
     * Returns the number of the month in year.
     * 
     * @return the month number, between 1 and 12
     */
    public int getMonth() {
        return cal.get(Calendar.MONTH) + 1;
    }

    /**
     * Returns the month number as String of length 2.
     * Leading zero is added, for example January returns as "01".
     */
    public String getMonthString() {
        int month = getMonth();
        return (month < 10 ? "0" + month : String.valueOf(month));
    }

    /**
     * Returns a new month by adding or substracting the given number of months.
     * 
     * @param num the number of months to add.
     * @return the calculated new month
     */
    public LoggedMonth addMonths(int num) {
        GregorianCalendar calculated = (GregorianCalendar) (cal.clone());
        calculated.add(Calendar.MONTH, num);
        return new LoggedMonth(calculated);
    }

    /**
     * Returns the next month following this month.
     */
    public LoggedMonth nextMonth() {
        return addMonths(1);
    }

    /**
     * Internally swaps the values of the two months.
     * Use this to fix from-until order, for example.
     */
    public static void swapMonths(LoggedMonth a, LoggedMonth b) {
        GregorianCalendar tmp = a.cal;
        b.cal = a.cal;
        a.cal = tmp;
    }

    /**
     * Returns true, if the given month is before this month.
     */
    public boolean before(LoggedMonth other) {
        return this.cal.before(other.cal);
    }

    /**
     * Returns true, if the given month is after this month.
     */
    public boolean after(LoggedMonth other) {
        return this.cal.after(other.cal);
    }

    /**
     * Returns true, if the given month is equal to this month.
     */
    public boolean equals(LoggedMonth other) {
        return (other != null) && (other.getYear() == getYear()) && (other.getMonth() == getMonth());
    }

    @Override
    public int hashCode() {
        return getYear() * 100 + getMonth();
    }

    @Override
    public String toString() {
        return getYearString() + "-" + getMonthString();
    }

    /** Returns a gregorian calendar representation of this month */
    public GregorianCalendar toCalendar() {
        return cal;
    }

    /**
     * Returns the minimum month allowed in log file analysis.
     * This is configured by
     * 
     * <code>
     * MIL.StatisticsServlet.MinYear
     * MIL.StatisticsServlet.MinMonth
     * </code>
     */
    public static LoggedMonth getMinimum() {
        MCRConfiguration config = MCRConfiguration.instance();
        int minYear = config.getInt(CONFIG_MINYEAR);
        int minMonth = config.getInt(CONFIG_MINMONTH);
        return new LoggedMonth(minYear, minMonth);
    }

    /**
     * Returns the maximum month allowed in log file analysis.
     * This is the month we had yesterday (assuming log analysis runs nightly).
     */
    public static LoggedMonth getMaximum() {
        GregorianCalendar yesterday = new GregorianCalendar();
        yesterday.add(GregorianCalendar.DAY_OF_MONTH, -1);
        return new LoggedMonth(yesterday);
    }
}

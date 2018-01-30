/**
 * $Revision: 26085 $ 
 * $Date: 2013-02-06 11:12:04 +0100 (Mi, 06 Feb 2013) $
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

/**
 * Counts the number of accesses for a given month and a single object
 * 
 * @author Frank L\u00FCtzenkirchen
 */
public class CounterForMonth {

    /** The number of accesses counted so far */
    private int count;

    /** The month this counter belongs to */
    private LoggedMonth month;

    /** Creates a new counter for the given month */
    public CounterForMonth(LoggedMonth month) {
        this.month = month;
    }

    /** Increments the counter by the given number of accesses */
    public void incrementBy(int num) {
        count += num;
    }

    /** Returns the number of accesses counted so far */
    public int getCount() {
        return count;
    }

    /** Returns the month this counter belongs to */
    public LoggedMonth getMonth() {
        return month;
    }
}

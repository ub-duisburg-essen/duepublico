/**
 * $Revision: 26103 $ 
 * $Date: 2013-02-07 09:25:19 +0100 (Do, 07 Feb 2013) $
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

import java.util.ArrayList;
import java.util.List;

/**
 * Counts the number of accesses to a single object, sequentially for each month
 * 
 * @author Frank L\u00FCtzenkirchen
 */
public class CounterForObject {

    /** The object that's accesses are counted here */
    private LoggedObject object;

    /** The total number of accesses in the month currently evaluated */
    private CounterForMonth currentCounter;

    /** The access counts of all months already evaluated */
    private List<CounterForMonth> counters = new ArrayList<CounterForMonth>();

    /** Creates a new counter for the given logged object */
    public CounterForObject(LoggedObject object) {
        this.object = object;
    }

    /** Returns the counter of the month currently evaluated */
    public CounterForMonth getCurrentMonthCounter() {
        return currentCounter;
    }

    /** Returns access counts of all months completely evaluated so far */
    public List<CounterForMonth> getCountersForMonths() {
        return counters;
    }

    /** Indicates that from now on a new month is evaluated. */
    public void beginMonth(LoggedMonth month) {
        currentCounter = new CounterForMonth(month);
        for (LoggedObject child : object.getChildren())
            child.getCounter().beginMonth(month);
    }

    /** Finishes counting accesses to this logged object and its children for the current month. */
    public void finishMonth() {
        counters.add(currentCounter);
        for (LoggedObject child : object.getChildren())
            child.getCounter().finishMonth();
    }

    /** Increments the counter of the current month by the number of accesses stored in the given data line */
    public void count(String lineOfLogFile) {
        String count = lineOfLogFile.split(" ", 3)[1];
        currentCounter.incrementBy(Integer.parseInt(count));
    }
}

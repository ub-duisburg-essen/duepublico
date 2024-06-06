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
        for (LoggedObject child : object.getChildren()) {
            child.getCounter().beginMonth(month);
        }
    }

    /** Finishes counting accesses to this logged object and its children for the current month. */
    public void finishMonth() {
        counters.add(currentCounter);
        for (LoggedObject child : object.getChildren()) {
            child.getCounter().finishMonth();
        }
    }

    /** Increments the counter of the current month by the number of accesses stored in the log file line */
    public void count(String count) {
        int numAccess = Integer.parseInt(count);
        currentCounter.incrementBy(numAccess);
    }
}

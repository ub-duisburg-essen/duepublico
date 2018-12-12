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

package unidue.ub.duepublico.statistics.series;

public class StatisticDates {

    private int minYear;

    private int minMonth;

    private int maxYear;

    private int maxMonth;

    
    public StatisticDates(int minYear, int minMonth, int maxYear, int maxMonth) {
        super();
        this.minYear = minYear;
        this.minMonth = minMonth;
        this.maxYear = maxYear;
        this.maxMonth = maxMonth;
    }

    String getRange() {
        return minMonth + "/" + minYear + "-" + maxMonth + "/" + maxYear;
    }

    int getMinMonthForYear(int year) {
        return year == minYear ? minMonth : 1;
    }

    int getMaxMonthForYear(int year) {
        return year == maxYear ? maxMonth : 12;
    }

    public int getMinYear() {
        return minYear;
    }

    public void setMinYear(int minYear) {
        this.minYear = minYear;
    }

    public int getMinMonth() {
        return minMonth;
    }

    public void setMinMonth(int minMonth) {
        this.minMonth = minMonth;
    }

    public int getMaxYear() {
        return maxYear;
    }

    public void setMaxYear(int maxYear) {
        this.maxYear = maxYear;
    }

    public int getMaxMonth() {
        return maxMonth;
    }

    public void setMaxMonth(int maxMonth) {
        this.maxMonth = maxMonth;
    }
}
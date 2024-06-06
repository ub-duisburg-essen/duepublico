package unidue.ub.duepublico.statistics;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.jdom2.Element;

/**
 * Builds xml output for the collected statistical data
 *
 * @author Frank L\u00FCtzenkirchen
 */
public class OutputBuilder {

    /**
     * Builds an XML representation of all statistical data collected when
     * the buildStatistics() method of the given builder was called.
     *
     * @throws ParseException when timestamps in the log data file could not be parsed
     */
    public static Element buildXML(StatisticsBuilder builder) throws ParseException {
        Element statistics = new Element("statistics");
        statistics.addContent(buildXML(LoggedMonth.getMaximum(), "now"));
        statistics.addContent(buildXML(LoggedMonth.getMinimum(), "min"));
        for (LogFile logFile : builder.getEvaluatedLogFiles()) {
            statistics.addContent(buildXML(logFile));
        }
        for (LoggedObject object : builder.getLoggedObjects()) {
            statistics.addContent(buildXML(object));
        }
        return statistics;
    }

    /**
     * Builds an XML representation of the given logged object and all its child object,
     * and the statistical data collected for those objects.
     */
    public static Element buildXML(LoggedObject object) {
        Element xml = new Element("object");
        object.setAttributes(xml);
        xml.addContent(buildXML(object.getCounter()));
        for (LoggedObject child : object.getChildren()) {
            xml.addContent(buildXML(child));
        }
        return xml;
    }

    /**
     * Builds an XML representation of the counters for all months logged for a single object
     */
    public static List<Element> buildXML(CounterForObject cfo) {
        List<Element> xml = new ArrayList<Element>();

        for (CounterForMonth counter : cfo.getCountersForMonths()) {
            xml.add(buildXML(counter));
        }

        return xml;
    }

    /**
     * Builds an XML element to output the given counter and its number of accesses
     */
    public static Element buildXML(CounterForMonth counter) {
        Element xml = buildXML(counter.getMonth(), "num");
        xml.setText(String.valueOf(counter.getCount()));
        return xml;
    }

    /**
     * Builds an XML element representing that month.
     * The element will have the attributes year and month set.
     *
     * @param name the name of the new element created.
     */
    public static Element buildXML(LoggedMonth month, String name) {
        Element e = new Element(name);
        e.setAttribute("year", month.getYearString());
        e.setAttribute("month", month.getMonthString());
        return e;
    }

    /**
     * Builds an XML element representing that log file.
     * Attributes contain the timestamp of first and last access in the log file.
     *
     * @throws ParseException if timestamps in the log file could not be parsed
     */
    public static Element buildXML(LogFile file) throws ParseException {
        String first = file.getValue("FirstTime");
        String last = file.getValue("LastTime");

        if ("0".equals(first)) {
            // Workaround for missing first logged access, assume 1st day of month
            first = last.substring(0, 6) + "01000000";
        }

        Element xml = OutputBuilder.buildXML(file.getMonth(), "loggedMonth");
        xml.setAttribute("first", formatAccessTime(first)); // first access in month
        xml.setAttribute("last", formatAccessTime(last)); // last access in month
        return xml;
    }

    /** Format of date time values in AWStats data log file */
    private final static DateFormat dfIn = new SimpleDateFormat("yyyyMMddHHmmss");

    /** Format of date time values in output file */
    private final static DateFormat dfOut = new SimpleDateFormat("EEEE, dd.MM.yyyy HH:mm:ss");

    /** Reformats the given timestamp from the log file to the format wished in output */
    private static String formatAccessTime(String value) throws ParseException {
        Date date = dfIn.parse(value);
        return dfOut.format(date);
    }
}

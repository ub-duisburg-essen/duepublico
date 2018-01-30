package unidue.ub.duepublico.statistics;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import org.mycore.services.i18n.MCRTranslation;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class SearchStatisticsDataBuilder {

    private static final Logger LOG = LogManager.getLogger(SearchStatisticsDataBuilder.class);

    private static final String DATE_TYPE_CREATED = "created";

    private static final String DATE_TYPE_MODIFIED = "modified";

    private static final String NODE_NAME_DATE = "date";

    private static final String ATT_NAME_TYPE = "type";

    private static final String ATT_NAME_FORMAT = "format";

    private static final SimpleDateFormat LABEL_FORMAT = new SimpleDateFormat("MM/yyyy");

    /**
     * Groups documents of target {@link NodeList} into different date intervals and retrieves the
     * count of documents by target month diffs.
     * The month differences must be integer numbers seperated by semicolons ("1;2;3"). In addition to
     * the given diffs the current date and the date of 01/01/1970 are set as base start and end for the
     * intervals. The diffs are additions which are added to the current date.
     * Ex. <code>month</code> are set to -1;-2;-4. The resulting intervals are if now is 31.12.2010:
     * <ul>
     *  <li>31.12.2010 - 30.11.2010</li>
     *  <li>29.11.2010 - 30.10.2010</li>
     *  <li>29.10.2010 - 31.08.2010</li>
     *  <li>30.08.2010 - 01.01.1970</li>
     * </ul>
     * The <code>docs</code> must be a list of <code>document</code> nodes, which contain the
     * <code>date type="created|modified"</code> dates.
     * @param docs
     * @param monthDiffs
     * @return  a string in the format <code>['label for interval', 10],['another label for interval', 5]</code>
     */
    public static String docsCountByModificationIntervals(NodeList docs, String monthDiffs) {
        LOG.debug("diffs: " + monthDiffs);

        String[] splittedDiffs = monthDiffs.split(";");

        Integer[] parsedDiffs = new Integer[splittedDiffs.length];
        for (int i = 0; i < splittedDiffs.length; i++)
            parsedDiffs[i] = Integer.valueOf(splittedDiffs[i]);

        return docsCountByModificationIntervals(docs, parsedDiffs);
    }

    /**
     * Does the work for {@link SearchStatisticsDataBuilder#docsCountByModificationIntervals(NodeList, String)}
     * @param docs
     * @param monthDiffs
     * @return
     */
    public static String docsCountByModificationIntervals(NodeList docs, Integer[] monthDiffs) {

        // calculate intervals
        List<Calendar> intervalDates = new ArrayList<Calendar>();

        // first date is now
        Calendar now = new GregorianCalendar();
        intervalDates.add(now);
        for (int diff : monthDiffs) {
            // each diff is set by current datetime
            Calendar c = new GregorianCalendar();
            c.add(Calendar.MONTH, diff);
            intervalDates.add(c);
        }

        // if a relevant date is before last date it is added to the default
        // interval (last date before X before big bang)
        Calendar bigBang = new GregorianCalendar();
        bigBang.setTimeInMillis(0);
        intervalDates.add(bigBang);
        int[] pots = new int[intervalDates.size() - 1];

        // calculate dates which are relevant for stats
        List<Calendar> relevantDocDates = new ArrayList<Calendar>();
        for (int i = 0; i < docs.getLength(); i++) {
            Node doc = (Node) docs.item(i);

            LOG.debug("processing document: " + doc.getAttributes().getNamedItem("id").getNodeValue());

            Calendar created = getDate(doc, DATE_TYPE_CREATED);
            Calendar modified = getDate(doc, DATE_TYPE_MODIFIED);

            // modified dates are preferred over created dates
            if (modified != null)
                relevantDocDates.add(modified);
            else if (created != null)
                relevantDocDates.add(created);
        }

        // calculate how many documents are found inside the calculated
        // intervals
        for (Calendar calendar : relevantDocDates) {

            for (int i = 0; i < intervalDates.size() - 1; i++) {
                Calendar start = intervalDates.get(i);
                Calendar end = intervalDates.get(i + 1); // end before start

                if (calendar.before(start) && calendar.after(end)) {
                    pots[i] += 1;
                    break;
                }
            }
        }

        StringBuffer result = new StringBuffer();
        for (int i = 0; i < pots.length; i++) {
            Calendar start = intervalDates.get(i);
            String label;
            if (i == pots.length - 1) {
                // handle last item separatly
                label = MCRTranslation.translate("stats.interval.last.label", LABEL_FORMAT.format(start.getTime()));
            } else {
                Calendar end = intervalDates.get(i + 1);
                label = MCRTranslation.translate("stats.interval.label", LABEL_FORMAT.format(start.getTime()), LABEL_FORMAT.format(end
                        .getTime()));

            }
            result.append("['");
            result.append(label);
            result.append("',");
            result.append(pots[i]);
            result.append("],");
        }
        LOG.debug("docs count result:  " + result.toString());
        return result.toString();
    }

    /**
     * Retrieves of the given document node the date as {@link Calendar} of target
     * type or <code>null</code> if nothing could be found.
     * @param document  contains the <code>document</code> node
     * @param type  <code>created|modified</code>
     * @return
     */
    private static Calendar getDate(Node document, String type) {

        Calendar result = null;

        // go through document elements
        NodeList docElements = document.getChildNodes();
        for (int j = 0; j < docElements.getLength() && result == null; j++) {
            Node element = docElements.item(j);

            // check element if it is a date
            if (NODE_NAME_DATE.equals(element.getNodeName())) {

                // check for given type
                NamedNodeMap attributes = element.getAttributes();
                Node typeAtt = attributes.getNamedItem(ATT_NAME_TYPE);
                String typeValue = typeAtt != null ? typeAtt.getNodeValue() : null;

                if (typeValue != null && type.equalsIgnoreCase(typeValue)) {

                    // format of date has to be given as pattern for
                    // SimpleDateFormat
                    Node formatAtt = attributes.getNamedItem(ATT_NAME_FORMAT);
                    String formatValue = formatAtt != null ? formatAtt.getNodeValue() : null;

                    // the text value has to be retrieved as a node from from the date tag (<date type=...>01.01.1970</date>)
                    String elementValue = element.getChildNodes().item(0).getNodeValue();

                    if (formatValue != null && elementValue != null) {
                        SimpleDateFormat format = new SimpleDateFormat(formatValue);
                        try {
                            // try parsing the value of the date element with
                            // given format
                            Date date = format.parse(elementValue);
                            result = new GregorianCalendar();

                            // date could be created
                            result.setTime(date);
                        } catch (ParseException e) {
                            LOG.error("document " + document.getAttributes().getNamedItem("id").getNodeValue() + " has invalid date data");
                        }
                    }
                }
            }
        }
        return result;
    }
}

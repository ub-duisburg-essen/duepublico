package unidue.ub.duepublico.statistics;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import org.jdom2.Element;
import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * Represents an objects thats number of accesses should be determined from the log data files.
 * A logged object may contain other logged objects that hierarchically belong to it, for example
 * a document object contains derivate object, which contain file objects belonging to it.
 *
 * @author Frank L\u00FCtzenkirchen
 */
public abstract class LoggedObject {

    /**
     * When a log line contains these patterns, it logs access to this object
     */
    protected List<Pattern> myPatterns = new ArrayList<Pattern>();

    protected void compilePatterns(List<String> patterns, MCRObjectID oid) {
        for (String pattern : patterns) {
            pattern = pattern.replace("NR", String.valueOf(oid.getNumberAsInteger())); // Legacy MILESS patterns
            pattern = pattern.replace("OID", oid.toString()); // Current patterns containing MCRObjectID
            myPatterns.add(Pattern.compile(pattern));
        }
    }

    /**
     * The logged objects that are contained in this logged object and should be handled, too.
     * For example, a document object contains derivate object, which contain file objects belonging to it.
     */
    private List<LoggedObject> children = new ArrayList<LoggedObject>();

    /**
     * Inspects the given log line from an AWStats data file,
     * decides if the line is related to this logged object,
     * and if so increments the number of accesses logged by that line.
     *
     * @param line a line from one of the AWStats data sections that contain access counts
     * @return true, if this object's accesses are logged by that line. This indicates the invoker that no other objects should be checked for that line.
     */
    public abstract boolean isHandled(String url, String count);

    /**
     * Utility method to call the isHandled() method on all children of this logged object,
     * until the first child reports that it handles the given line, so the other children
     * can be skipped.
     *
     * @param path the path from one of the AWStats data sections that contain access counts
     * @return true, if this object's children are logged by that path.
     */
    protected boolean handleChildren(String path, String count) {
        for (LoggedObject child : children) {
            if (child.isHandled(path, count)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Adds a child logged object to this logged object
     */
    protected void addChild(LoggedObject child) {
        children.add(child);
    }

    /**
     * Returns all child logged objects of this object
     */
    public List<LoggedObject> getChildren() {
        return children;
    }

    /**
     * Counts the number of accesses to this single logged object.
     * It does not count the access to the child objects, they have their own counter!
     */
    protected CounterForObject counter = new CounterForObject(this);

    /**
     * Returns the counter for the accesses to this single logged object.
     * It does not count the access to the child objects, they have their own counter!
     */
    public CounterForObject getCounter() {
        return counter;
    }

    /**
     * When data of this logged object is outputted to XML, subclasses can add
     * their own attributes to the output. For example, an object should add its ID
     * or title to the given output element.
     *
     * @param xml the XML element representing this logged object, containing all statistical data
     */
    public abstract void setAttributes(Element xml);
}

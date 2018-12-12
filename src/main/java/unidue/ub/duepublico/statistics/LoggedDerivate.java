package unidue.ub.duepublico.statistics;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.jdom2.Element;
import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * Represents a derivate for that access should be evaluated.
 * Dynamically adds the files as child objects that should also be logged,
 * whenever a file path is detected in the log line.
 *
 * @author Frank L\u00FCtzenkirchen
 */
public class LoggedDerivate extends LoggedObject {

    private static final List<String> PATH_PATTERNS = new ArrayList<String>();

    static {
        PATH_PATTERNS.add("/servlets/MCRFileNodeServlet/OID/([^?]+)(\\?.*)?");
        PATH_PATTERNS.add("/servlets/DerivateServlet/Derivate-NR.xml.*");
        PATH_PATTERNS.add("/servlets/DerivateServlet/Derivate-NR/([^?]+)/_virtual/.*(\\?.*)?");
        PATH_PATTERNS.add("/servlets/DerivateServlet/Derivate-NR/([^?]+)(\\?.*)?");
    }

    /** The ID of the derivate */
    private MCRObjectID oid;

    /**
     * Contained and logged files of this derivate, by file path
     */
    private Map<String, LoggedFile> files = new HashMap<String, LoggedFile>();

    public LoggedDerivate(MCRObjectID oid) {
        this.oid = oid;

        compilePatterns(PATH_PATTERNS, oid);
    }

    /** Returns the derivate ID */
    public MCRObjectID getDerivateId() {
        return this.oid;
    }

    @Override
    public void setAttributes(Element xml) {
        xml.setAttribute("type", "derivate");
        xml.setAttribute("id", oid.toString());
    }

    @Override
    public boolean isHandled(String path, String count) {
        for (Pattern pattern : myPatterns) {
            Matcher matcher = pattern.matcher(path);
            if (matcher.matches()) {
                if (matcher.groupCount() > 0) {
                    String filePath = matcher.group(1);
                    LoggedFile file = getLoggedFile(filePath);
                    return file.isHandled(path, count);
                } else {
                    counter.count(count);
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Returns the LoggedFile that is related to the given file path.
     * If not already existing, it is dynamically created as a child object.
     */
    public LoggedFile getLoggedFile(String path) {
        LoggedFile file = files.get(path);
        if (file == null) {
            file = buildFile(path);
        }
        return file;
    }

    /**
     * Creates a new LoggedFile that is related to the given file path,
     * and adds it to the child object
     */
    private LoggedFile buildFile(String path) {
        LoggedFile file = new LoggedFile(path);
        addChild(file);

        // The newly created file does not know which month currently is evaluated, so let it know
        LoggedMonth currentMonth = counter.getCurrentMonthCounter().getMonth();
        file.getCounter().beginMonth(currentMonth);

        files.put(path, file);
        return file;
    }
}

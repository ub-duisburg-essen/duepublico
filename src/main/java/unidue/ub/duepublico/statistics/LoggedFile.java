package unidue.ub.duepublico.statistics;

import org.jdom2.Element;

/**
 * Represents a file for that access should be evaluated.
 * Files are dynamically added as children of logged derivates,
 * whenever a file path is detected in the log line.
 *
 * @author Frank L\u00FCtzenkirchen
 */
public class LoggedFile extends LoggedObject {

    /** The relative path to the file within the derivate */
    protected String path;

    LoggedFile(String path) {
        this.path = path;
    }

    @Override
    public void setAttributes(Element xml) {
        xml.setAttribute("type", "file");
        xml.setAttribute("path", path);
    }

    @Override
    public boolean isHandled(String path, String count) {
        counter.count(count);
        return true;
    }
}

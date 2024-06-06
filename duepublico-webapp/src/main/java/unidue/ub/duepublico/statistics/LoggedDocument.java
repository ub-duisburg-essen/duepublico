package unidue.ub.duepublico.statistics;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.regex.Pattern;

import org.jdom2.Element;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * Represents a document for that access should be evaluated. Automatically adds
 * the derivates as child objects that should also be logged.
 *
 * @author Frank L\u00FCtzenkirchen
 */
public class LoggedDocument extends LoggedObject {

    private static final List<String> PATH_PATTERNS = new ArrayList<String>();

    static {
        PATH_PATTERNS.add("/servlets/DocumentServlet\\?(.+=.*\\&)?id=NR(\\&.*)?");
        PATH_PATTERNS.add("/rsc/stat/OID.css(\\?.*)?");
        PATH_PATTERNS.add("/go/ALIAS");
    }

    /** The ID of the document */
    private MCRObjectID oid;

    public LoggedDocument(MCRObjectID oid) throws Exception {
        this.oid = oid;

        compilePatterns(PATH_PATTERNS, oid, true);

        List<MCRObjectID> derivateIDs = MCRMetadataManager.getDerivateIds(oid, 0, TimeUnit.MILLISECONDS);
        for (MCRObjectID derivateID : derivateIDs) {
            addChild(new LoggedDerivate(derivateID));
        }
    }

    @Override
    public void setAttributes(Element xml) {
        xml.setAttribute("type", "document");
        xml.setAttribute("id", oid.toString());
    }

    @Override
    public boolean isHandled(String path, String count) {
        if (isLoggedBy(path)) {
            counter.count(count);
            return true;
        }
        return handleChildren(path, count);
    }

    /** Checks if access to this document is logged by the given line */
    private boolean isLoggedBy(String line) {
        for (Pattern pattern : myPatterns) {
            line = line.split("\\s")[0];
            if (pattern.matcher(line).matches()) {
                return true;
            }
        }
        return false;
    }
}

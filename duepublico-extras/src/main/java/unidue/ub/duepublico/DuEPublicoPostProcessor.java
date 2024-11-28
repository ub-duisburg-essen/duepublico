package unidue.ub.duepublico;

import java.io.IOException;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.mycore.common.MCRConstants;
import org.mycore.mir.editor.MIREditorUtils;
import org.mycore.mir.editor.MIRPostProcessor;

public class DuEPublicoPostProcessor extends MIRPostProcessor {

    private static final String XPATH_NOTE = "//mods:mods/mods:note[string-length(text()) > 0]";

    private XPathExpression<Element> nxp;

    public DuEPublicoPostProcessor() {
        super();

        nxp = XPathFactory.instance().compile(XPATH_NOTE, Filters.element(), null, MCRConstants.MODS_NAMESPACE);
    }

    @Override
    public Document process(Document oldXML) throws IOException, JDOMException {
        final Document newXML = oldXML.clone();

        for (Element note : nxp.evaluate(newXML)) {
            String textBefore = note.getText();

            if (!(textBefore.contains("<") || textBefore.contains("&")))
                continue; // does not smell like html

            String textAfter = MIREditorUtils.getXHTMLSnippedString(textBefore);
            if (textBefore.equals(textAfter))
                continue; // no change
            else
                note.setText(textAfter);
        }

        return super.process(newXML);
    }
}

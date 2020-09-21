package unidue.ub.duepublico;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Objects;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.DOMOutputter;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Entities;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRPersistenceException;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.MCRObjectCommands;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mods.MCRMODSWrapper;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@MCRCommandGroup(name = "DuEPublico migration 2020.06")
public class NoteHTMLMigration {

    public static final Logger LOGGER = LogManager.getLogger();

    @MCRCommand(
        syntax = "fix html in mods:note of all objects",
        help = "fixes invalid html in mods:note by converting to xhtml syntax")
    public static void selectObjectWhichNeedMigration() {
        for (String oid : MCRXMLMetadataManager.instance().listIDsOfType("mods")) {
            fixHTMLinMODSNote(oid);
        }
    }

    @MCRCommand(
        syntax = "fix html in mods:note of object {0}",
        help = "fixes invalid html in mods:note by converting to xhtml syntax")
    public static void fixHTMLinMODSNote(String oid) {
        final MCRObjectID objectID = MCRObjectID.getInstance(oid);
        final MCRObject object = MCRMetadataManager.retrieveMCRObject(objectID);

        final Element mods = new MCRMODSWrapper(object).getMODS();

        boolean fixed = false;
        for (Element note : mods.getChildren("note", MCRConstants.MODS_NAMESPACE)) {
            String textBefore = note.getText();
            if (!textBefore.contains("<"))
                continue; // does not smell like html

            String textAfter = convert(textBefore);
            if (textBefore.equals(textAfter))
                continue; // no change

            if (textAfter == null) { // conversion did not work
                System.out.println("Can't convert " + oid);
                System.out.println("--------------------------------");
                System.out.println("before: " + textBefore);
                System.out.println(" after: " + textAfter);
                System.out.println("--------------------------------");
                continue;
            }

            note.setText(textAfter);
            fixed = true;
        }

        if (fixed)
            try {
                MCRMetadataManager.update(object);
                System.out.println("Migrated mods:note in " + oid);
            } catch (Exception ex) {
                LOGGER.warn(ex);
            }
    }

    private static String convert(String text) {
        try {
            byte[] data = text.getBytes(StandardCharsets.UTF_8);
            final org.jsoup.nodes.Document jsoupDoc = Jsoup.parse(new ByteArrayInputStream(data), null, "");
            jsoupDoc.outputSettings().prettyPrint(false);
            jsoupDoc.outputSettings().escapeMode(Entities.EscapeMode.xhtml);
            jsoupDoc.outputSettings().syntax(org.jsoup.nodes.Document.OutputSettings.Syntax.xml);
            String tmp = jsoupDoc.body().html();

            String test = "<test>" + tmp + "</test>";
            new SAXBuilder().build(new ByteArrayInputStream(test.getBytes(StandardCharsets.UTF_8)));

            return tmp;
        } catch (Exception ex) {
            return null;
        }
    }
}

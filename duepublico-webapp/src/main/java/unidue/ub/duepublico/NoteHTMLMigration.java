package unidue.ub.duepublico;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.common.MCRConstants;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mir.editor.MIREditorUtils;
import org.mycore.mods.MCRMODSWrapper;

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

            if (!(textBefore.contains("<") || textBefore.contains("&")))
                continue; // does not smell like html

            String textAfter = MIREditorUtils.getXHTMLSnippedString(textBefore);
            if (textBefore.equals(textAfter))
                continue; // no change

            System.out.println("--------------------------------");
            System.out.println("before: " + textBefore);
            System.out.println(" after: " + textAfter);
            System.out.println("--------------------------------");

            if (textAfter == null) { // conversion did not work
                System.out.println("WARNING: Can't convert " + oid);
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
}

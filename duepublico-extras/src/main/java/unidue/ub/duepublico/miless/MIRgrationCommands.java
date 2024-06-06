package unidue.ub.duepublico.miless;

import org.mycore.frontend.cli.MCRAbstractCommands;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;

@MCRCommandGroup(name = "MIRgration Commands")
public class MIRgrationCommands extends MCRAbstractCommands {

    @org.mycore.frontend.cli.annotation.MCRCommand(syntax = "mirgrate document {0} testing {1} force {2}",
        help = "Migrate metadata, derivates and files of document from miless-based DuEPublico server.",
        order = 10)
    public static void mirgrateDocument(String documentID, String justTesting, String force) {

        boolean bJustTesting = "true".equals(justTesting);
        boolean bForce = "true".equals(force);

        MIRgrator mirgrator = new MIRgrator(documentID);
        mirgrator.setJustTesting(bJustTesting);
        mirgrator.setIgnoreMetadataConversionErrors(bForce);
        mirgrator.run();

        if (!(mirgrator.getErrors().isEmpty() || bJustTesting)) {
            throw new MIRgrationException("Errors detected migrating document " + documentID, null);
        }
    }
}

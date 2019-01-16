package unidue.ub.duepublico.miless;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.frontend.cli.MCRAbstractCommands;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;

@MCRCommandGroup(name = "MIRgration Commands")
public class MIRgrationCommands extends MCRAbstractCommands {

    private static final Logger LOGGER = LogManager.getLogger();

    @org.mycore.frontend.cli.annotation.MCRCommand(syntax = "mirgrate document {0} testing {1} force {2}",
        help = "Migrate metadata, derivates and files of document from miless-based DuEPublico server.",
        order = 10)
    public static void mirgrateDocument(String documentID, String justTesting,
        String ignoreMetadataConversionErrors) {
        MIRgrator mirgrator = new MIRgrator(documentID);
        mirgrator.setJustTesting("true".equals(justTesting));
        mirgrator.setIgnoreMetadataConversionErrors("true".equals(ignoreMetadataConversionErrors));
        mirgrator.run();
        for (String error : mirgrator.getErrors()) {
            LOGGER.warn("Error: {}", error);
        }
    }
}

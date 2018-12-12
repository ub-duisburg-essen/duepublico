package unidue.ub.duepublico.miless;

import java.io.IOException;

import org.jdom2.JDOMException;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRPersistenceException;
import org.mycore.datamodel.common.MCRActiveLinkException;
import org.mycore.frontend.cli.MCRAbstractCommands;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.xml.sax.SAXException;

@MCRCommandGroup(name = "MIRgration Commands")
public class MIRgrationCommands extends MCRAbstractCommands {

    @org.mycore.frontend.cli.annotation.MCRCommand(syntax = "mirgrate document {0}",
        help = "Migrate metadata, derivates and files of document from miless-based DuEPublico server",
        order = 10)
    public static void mirgrateDocument(String documentID) throws MCRPersistenceException, MCRAccessException,
        MCRActiveLinkException, JDOMException, IOException, SAXException {
        MIRgrator mirgrator = new MIRgrator(documentID);
        try {
            mirgrator.mirgrate();
        } finally {
            for (String error : mirgrator.getErrors()) {
                System.out.println(error);
            }
        }
    }

    @org.mycore.frontend.cli.annotation.MCRCommand(syntax = "check mirgrate document {0}",
        help = "Checks if document can be migrated, without actually doing it",
        order = 11)
    public static void checkMirgrateDocument(String documentID) throws MCRPersistenceException, MCRAccessException,
        MCRActiveLinkException, JDOMException, IOException, SAXException {
        MIRgrator mirgrator = new MIRgrator(documentID);
        mirgrator.check();
    }
}

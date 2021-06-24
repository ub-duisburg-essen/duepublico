package unidue.ub.duepublico.media;

import static org.junit.Assert.assertNotNull;

import java.io.IOException;

import org.jdom2.Element;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.junit.Test;
import org.mycore.common.MCRTestCase;
import org.mycore.common.xml.MCRURIResolver;

public class WowzaTest extends MCRTestCase {
    
    @Test
    public void testPeriodResolverSingle() throws IOException {
        Element input = MCRURIResolver.instance().resolve("wowza");
        new XMLOutputter(Format.getPrettyFormat()).output(input, System.out);
        assertNotNull(input);
    }
}
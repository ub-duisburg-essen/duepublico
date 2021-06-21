package unidue.ub.duepublico.media;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

public class WowzaResolver implements URIResolver {

    @Override
    public Source resolve(String href, String base) throws TransformerException {
       System.out.println("WowzaResolver ------------------------------------ " + href);
       return null;

   }
}

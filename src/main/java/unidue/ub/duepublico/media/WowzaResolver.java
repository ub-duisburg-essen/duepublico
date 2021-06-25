package unidue.ub.duepublico.media;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

public class WowzaResolver implements URIResolver {

    @Override
    public Source resolve(String href, String base) throws TransformerException {
        //System.out.println("WowzaResolver ------------------------------------ " + href);
        MediaFileEntryManager mediaFileEntryManager = new MediaFileEntryManager();
        
        
        mediaFileEntryManager.getSectorPath("duepublico_derivate_00072643/Bibtag_Vortrag_CC_Certificate.mp4");
       
        //String wowzaLink = MediaService.buildWowzaLink("0007/34/duepublico_derivate_00073400/Beisswenger_OGeSoMo.mp4");
        return null;

    }
}

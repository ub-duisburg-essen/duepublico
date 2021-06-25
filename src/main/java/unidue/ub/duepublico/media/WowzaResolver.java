package unidue.ub.duepublico.media;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

public class WowzaResolver implements URIResolver {

    @Override
    public Source resolve(String href, String base) throws TransformerException {
        //System.out.println("WowzaResolver ------------------------------------ " + href);
        String storageId = href.substring(href.indexOf(":") + 1);

        MediaFileManager mediaFileManager = new MediaFileManager();

        if (mediaFileManager.isWowzaEnabled()) {
            String sectorPath = mediaFileManager.getSectorPath(storageId);

            String wowzaLink = mediaFileManager.buildWowzaLink(sectorPath);
            System.out.println(wowzaLink);
        }

        //String wowzaLink = MediaService.buildWowzaLink("0007/34/duepublico_derivate_00073400/Beisswenger_OGeSoMo.mp4");
        return null;

    }
}

package unidue.ub.duepublico.media;

import java.io.File;
import java.io.IOException;

import org.mycore.datamodel.ifs.MCRContentStoreFactory;
import org.mycore.datamodel.ifs2.MCRCStoreIFS2;
import org.mycore.datamodel.ifs2.MCRFile;

public class MediaFileEntryManager {

    public MediaFileEntryManager() {
    }

    
    public String getSectorPath(String storageId) {
        MCRCStoreIFS2 ifs2 = (MCRCStoreIFS2) MCRContentStoreFactory.getStore("IFS2");
        try {
            File localfile = ifs2.getLocalFile(storageId);
            String localpath = localfile.getAbsolutePath();
            localpath = localpath.replaceAll("\\", "/"); 
            
            String sectorPath[] = localpath.split("duepublico");
            System.out.println(sectorPath[1]);
            
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        
       
        return null;
    }

}

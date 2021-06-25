package unidue.ub.duepublico.media;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.datamodel.ifs.MCRContentStoreFactory;
import org.mycore.datamodel.ifs2.MCRCStoreIFS2;

public class MediaFileManager {
    private static final Logger LOGGER = LogManager.getLogger();

    public static final String CONFIG_PREFIX = "DuEPublico.MediaService.";

    public static final String WOWZA_SERVER_URL = MCRConfiguration2.getString(CONFIG_PREFIX + "Wowza.ServerURL")
        .orElse(null);

    public static final String WOWZA_STORAGE_PATH = MCRConfiguration2.getString(CONFIG_PREFIX + "Wowza.StoragePath")
        .orElse(null);

    public static final String WOWZA_PARAM_PREFIX = MCRConfiguration2.getString(CONFIG_PREFIX + "Wowza.ParamPrefix")
        .orElse("");

    public static final String WOWZA_SHARED_SECRET = MCRConfiguration2.getString(CONFIG_PREFIX + "Wowza.SharedSecret")
        .orElse(null);;

    public static final int WOWZA_VALIDITY_HOURS = MCRConfiguration2.getInt(CONFIG_PREFIX + "Wowza.ValidityHours")
        .orElse(2);;

    public MediaFileManager() {
    }

    public String getSectorPath(String storageId) {
        MCRCStoreIFS2 ifs2 = (MCRCStoreIFS2) MCRContentStoreFactory.getStore("IFS2");

        String sectorPath = null;
        try {
            File localfile = ifs2.getLocalFile(storageId);
            String localpath = localfile.getAbsolutePath();
            localpath = localpath.replace("\\", "/");

            String[] sectorPathSplit = localpath.split("/content/");
            sectorPath = sectorPathSplit[sectorPathSplit.length - 1];
        } catch (IOException e) {

            LOGGER.warn(e.getMessage());
        }
        return sectorPath;
    }

    public boolean isWowzaEnabled() {
        return WOWZA_SERVER_URL != null && WOWZA_STORAGE_PATH != null;
    }

    public String buildWowzaLink(String sectorPath) {

        String wowzaLink = WOWZA_SERVER_URL + WOWZA_STORAGE_PATH + sectorPath;

        if (WOWZA_SHARED_SECRET != null) {
            StringBuilder hashBuilder = new StringBuilder();

            hashBuilder.append(WOWZA_STORAGE_PATH + sectorPath);

            /*
             * Append the '?' character to the path that you created in the previous step.
             * This character separates the content path from the public SecureToken query
             * parameters that follow.
             */
            hashBuilder.append("?");

            /*
             * Append the public SecureToken query parameters, shared secret, and client IP
             * address (if applicable) to the '?' character that you created in the previous
             * step. These items MUST be in alphabetical order and separated by the '&'
             * character.
             */
            List<String> params = new ArrayList<>();

            ZonedDateTime now = ZonedDateTime.now();
            ZonedDateTime startTime = now;
            ZonedDateTime endTime = now.plusHours(WOWZA_VALIDITY_HOURS);

            params.add(WOWZA_SHARED_SECRET);
            params.add(WOWZA_PARAM_PREFIX + "endtime=" + endTime.toEpochSecond());
            params.add(WOWZA_PARAM_PREFIX + "starttime=" + startTime.toEpochSecond());
            params.sort(String::compareTo);
            hashBuilder.append(String.join("&", params));

            // build the hash
            String digestMethod = "SHA-512";
            try {
                MessageDigest digest = MessageDigest.getInstance(digestMethod);

                byte[] bytes = digest.digest(hashBuilder.toString().getBytes(Charset.forName("UTF-8")));
                String hash = Base64.getUrlEncoder().encodeToString(bytes);

                wowzaLink = wowzaLink + "/playlist.m3u8?wowzatokenhash="
                    + hash + "&" + WOWZA_PARAM_PREFIX + "starttime=" + Long.toString(startTime.toEpochSecond())
                    + "&" + WOWZA_PARAM_PREFIX + "endtime=" + Long.toString(endTime.toEpochSecond());

            } catch (NoSuchAlgorithmException e) {
                LOGGER.warn("could not create MessageDigest for " + digestMethod, e);
            }
        }
        return wowzaLink;
    }
}

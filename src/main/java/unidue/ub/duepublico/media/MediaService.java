package unidue.ub.duepublico.media;

import java.nio.charset.Charset;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

import org.mycore.common.config.MCRConfiguration2;

public class MediaService {

    public static final String CONFIG_PREFIX = "DuEPublico.MediaService.";

    public static String WOWZA_SERVER_URL;

    public static String WOWZA_STORAGE_PATH;

    public static String WOWZA_PARAM_PREFIX;

    public static String WOWZA_SHARED_SECRET;

    public static int WOWZA_VALIDITY_HOURS;

    static {
        WOWZA_SERVER_URL = MCRConfiguration2.getString("Wowza.ServerURL").orElse(null);

        WOWZA_STORAGE_PATH = MCRConfiguration2.getString("Wowza.StoragePath").orElse(null);
        WOWZA_VALIDITY_HOURS = MCRConfiguration2.getInt(CONFIG_PREFIX + "Wowza.ValidityHours").orElse(2);

        WOWZA_PARAM_PREFIX = MCRConfiguration2.getString("Wowza.ParamPrefix").orElse("");
        WOWZA_SHARED_SECRET = MCRConfiguration2.getString("Wowza.SharedSecret").orElse(null);
    }

    public static String buildWowzaLink(String input) {
        //input = "0007/34/duepublico_derivate_00073400/Beisswenger_OGeSoMo.mp4";

        if (WOWZA_SERVER_URL != null) {
            String wowzaLink = WOWZA_SERVER_URL + WOWZA_STORAGE_PATH + input;

            if (WOWZA_SHARED_SECRET != null) {
                StringBuilder hashBuilder = new StringBuilder();

                hashBuilder.append(WOWZA_STORAGE_PATH + input);

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
                    return input;
                }
            }
            return wowzaLink;
        }

        return input;
    }
}

package unidue.ub.duepublico;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.text.MessageFormat;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.sax.SAXResult;

import org.apache.fop.apps.EnvironmentalProfileFactory;
import org.apache.fop.apps.FOPException;
import org.apache.fop.apps.FOUserAgent;
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.FopFactoryBuilder;
import org.apache.fop.apps.MimeConstants;
import org.apache.fop.configuration.Configuration;
import org.apache.fop.configuration.ConfigurationException;
import org.apache.fop.configuration.DefaultConfigurationBuilder;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.xmlgraphics.io.Resource;
import org.apache.xmlgraphics.io.ResourceResolver;
import org.mycore.common.MCRClassTools;
import org.mycore.common.MCRCoreVersion;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.config.MCRConfigurationDir;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRSourceContent;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.common.xsl.MCRErrorListener;
import org.mycore.component.fo.common.fo.MCRFoFormatterInterface;

/**
 * This class implements the interface to use configured XSL-FO formatters for the layout service.
 * The class overrides mycore-fo/{@link org.mycore.component.fo.common.fo.MCRFoFormatterFOP MCRFoFormatterFOP}
 * to set the accessibility programmatically.
 */
public class DuEFoFormatterFOP implements MCRFoFormatterInterface {

    private static final Logger LOGGER = LogManager.getLogger();

    private final FopFactory fopFactory;

    final ResourceResolver resolver = new ResourceResolver() {
        public OutputStream getOutputStream(URI uri) throws IOException {
            URL url = MCRURIResolver.getServletContext().getResource(uri.toString());
            return url.openConnection().getOutputStream();
        }

        public Resource getResource(URI uri) throws IOException {
            MCRContent content;
            try {
                content = MCRSourceContent.getInstance(uri.toString());
                return new Resource(uri.getScheme(), content.getInputStream());
            } catch (TransformerException e) {
                LOGGER.error("Error while resolving uri: {}", uri);
            }

            return null;
        }
    };

    /**
     * instantiate DuEFoFormatterFOP
     */
    public DuEFoFormatterFOP() {
        FopFactoryBuilder fopFactoryBuilder;
        // use restricted io to prevent issues with font caching on some systems
        fopFactoryBuilder = new FopFactoryBuilder(
            EnvironmentalProfileFactory.createRestrictedIO(URI.create("resource:/"), resolver));
        final String foCfg = MCRConfiguration2.getString("MCR.LayoutService.FoFormatter.FOP.config").orElse("");
        if (!foCfg.isEmpty()) {
            try {
                URL configResource = MCRConfigurationDir.getConfigResource(foCfg);
                URLConnection con = configResource.openConnection();
                final DefaultConfigurationBuilder cfgBuilder = new DefaultConfigurationBuilder();
                final Configuration cfg;
                try (InputStream is = con.getInputStream();) {
                    cfg = cfgBuilder.build(is);
                }
                fopFactoryBuilder.setConfiguration(cfg);

                // FIXME Workaround to get hyphenation work in FOP.
                // FOP should use "hyphenation-base" to get base URI for patterns
                Optional<Configuration[]> hyphPat = Optional.ofNullable(cfg.getChildren("hyphenation-pattern"));
                hyphPat.ifPresent(configurations -> {
                    Map<String, String> hyphPatMap = new HashMap<>();
                    Arrays.stream(configurations).forEach(c -> {
                        try {
                            String lang = c.getAttribute("lang");
                            String file = c.getValue();

                            if ((lang != null && !lang.isEmpty()) && (file != null && !file.isEmpty())) {
                                hyphPatMap.put(lang, file);
                            }
                        } catch (Exception e) {
                        }
                    });
                    fopFactoryBuilder.setHyphPatNames(hyphPatMap);
                });

            } catch (ConfigurationException | IOException e) {
                LOGGER.error("Exception while loading FOP configuration from {}.", foCfg, e);
            }
        }
        fopFactory = fopFactoryBuilder.build();
        getTransformerFactory();
    }

    private static TransformerFactory getTransformerFactory() throws TransformerFactoryConfigurationError {
        TransformerFactory transformerFactory
            = MCRConfiguration2.getString("MCR.LayoutService.FoFormatter.transformerFactoryImpl")
                .map(impl -> TransformerFactory.newInstance(impl, MCRClassTools.getClassLoader()))
                .orElseGet(TransformerFactory::newInstance);
        transformerFactory.setURIResolver(MCRURIResolver.instance());
        transformerFactory.setErrorListener(MCRErrorListener.getInstance());
        return transformerFactory;
    }

    @Override
    public void transform(MCRContent input, OutputStream out) throws TransformerException, IOException {
        try (out) {
            final FOUserAgent userAgent = fopFactory.newFOUserAgent();
            userAgent.setAccessibility(true);

            userAgent.setProducer(new MessageFormat("MyCoRe {0} ({1})", Locale.ROOT)
                .format(new Object[] { MCRCoreVersion.getCompleteVersion(), userAgent.getProducer() }));

            final Fop fop = fopFactory.newFop(MimeConstants.MIME_PDF, userAgent, out);
            final Source src = input.getSource();
            final Result res = new SAXResult(fop.getDefaultHandler());
            Transformer transformer = getTransformerFactory().newTransformer();
            transformer.transform(src, res);
        } catch (FOPException e) {
            throw new TransformerException(e);
        }
    }
}
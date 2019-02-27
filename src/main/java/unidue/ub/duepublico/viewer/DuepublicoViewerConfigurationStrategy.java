package unidue.ub.duepublico.viewer;

import javax.servlet.http.HttpServletRequest;

import org.mycore.mir.viewer.MIRViewerConfigurationStrategy;
import org.mycore.viewer.configuration.MCRViewerConfiguration;
import org.mycore.viewer.configuration.MCRViewerConfigurationBuilder;

public class DuepublicoViewerConfigurationStrategy extends MIRViewerConfigurationStrategy {

    @Override
    protected MCRViewerConfiguration getPDF(HttpServletRequest request) {
        
        return MCRViewerConfigurationBuilder.pdf(request).mixin(MCRViewerConfigurationBuilder.plugins(request).get())
                .mixin(new DuepublicoViewerScrollbarConfiguration()).get();

    }
}
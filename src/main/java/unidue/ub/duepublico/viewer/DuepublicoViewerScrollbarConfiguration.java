package unidue.ub.duepublico.viewer;

import javax.servlet.http.HttpServletRequest;

import org.mycore.viewer.configuration.MCRViewerConfiguration;

public class DuepublicoViewerScrollbarConfiguration extends MCRViewerConfiguration {

    @Override
    public MCRViewerConfiguration setup(HttpServletRequest request) {
        super.setup(request);
        this.addLocalScript("duepublico-iview-scrollbar.js", false, isDebugMode(request));

        return this;
    }
}
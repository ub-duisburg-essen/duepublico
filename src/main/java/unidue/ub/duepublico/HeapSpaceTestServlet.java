package unidue.ub.duepublico;

import java.util.concurrent.TimeUnit;
import javax.servlet.annotation.WebServlet;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;

@WebServlet(name = "HeapSpaceTestServlet", urlPatterns = { "/servlets/HeapSpaceTestServlet" })
public class HeapSpaceTestServlet extends MCRServlet {

	private static final long serialVersionUID = 1L;

	private static final Logger LOGGER = LogManager.getLogger();

	@Override
	protected void doGetPost(MCRServletJob job) throws Exception {

		LOGGER.info("Reproducing java heap space error");

		
		while (true) {
			new Thread(() -> {
				try {
					TimeUnit.HOURS.sleep(1);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}).start();
		}
	}

}
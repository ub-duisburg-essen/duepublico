package unidue.ub.duepublico;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;
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

		LOGGER.info("Reproducing - java.lang.OutOfMemoryError: GC Overhead Limit Exceeded");

		
		 Map<Integer, String> dataMap = new HashMap<>();
	        Random r = new Random();
	        while (true) {
	            dataMap.put(r.nextInt(), String.valueOf(r.nextInt()));
	        }
	}

}
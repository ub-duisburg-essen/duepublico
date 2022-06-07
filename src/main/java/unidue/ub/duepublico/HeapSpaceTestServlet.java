package unidue.ub.duepublico;

import java.util.ArrayList;
import java.util.List;
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

		
//		 Map<Integer, String> dataMap = new HashMap<>();
//	        Random r = new Random();
//	        while (true) {
//	            dataMap.put(r.nextInt(), String.valueOf(r.nextInt()));
//	        }
		List<byte[]> list = new ArrayList<>();
		int index = 1;
		while (true) {
				// 1MB each loop, 1 x 1024 x 1024 = 1048576
				byte[] b = new byte[1048576];
				list.add(b);
				Runtime rt = Runtime.getRuntime();
				System.out.printf("[%d] free memory: %s%n", index++, rt.freeMemory());
		}
	}

}
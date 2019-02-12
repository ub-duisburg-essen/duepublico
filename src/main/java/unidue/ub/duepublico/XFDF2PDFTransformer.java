package unidue.ub.duepublico;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

import javax.xml.transform.TransformerException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.fdf.FDFDocument;
import org.apache.pdfbox.pdmodel.interactive.form.PDAcroForm;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.content.MCRByteContent;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRSourceContent;
import org.mycore.common.content.transformer.MCRContentTransformer;

/**
 * Reads a PDF file from the URI specified by MCR.ContentTransformer.[ID].PDF,
 * fills the form fields with the XFDF document given as source input,
 * returns the resulting PDF.
 *
 * @author Frank L\u00FCtzenkirchen
 */
public class XFDF2PDFTransformer extends MCRContentTransformer {

    private static Logger LOGGER = LogManager.getLogger();

    private String pdfURI;

    @Override
    public void init(String id) {
        super.init(id);

        String property = "MCR.ContentTransformer." + id + ".PDF";
        pdfURI = MCRConfiguration.instance().getString(property);
    }

    @Override
    public MCRContent transform(MCRContent source) throws IOException {
        try {
            LOGGER.info("will read PDF from URI " + pdfURI);
            MCRContent sourcePDF = MCRSourceContent.getInstance(pdfURI);
            PDDocument pdf = PDDocument.load(sourcePDF.getInputStream());

            PDAcroForm form = pdf.getDocumentCatalog().getAcroForm();
            FDFDocument fdf = FDFDocument.loadXFDF(source.getInputStream());
            form.importFDF(fdf);
            LOGGER.info("imported XFDF into PDF from " + pdfURI);

            MCRContent result = pdf2content(pdf);
            result.setMimeType("application/pdf");
            return result;
        } catch (TransformerException e) {
            throw new IOException(e);
        }

    }

    // Tried to use PDStream, but could'nt get it working
    private MCRContent pdf2content(PDDocument pdf) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        pdf.save(baos);
        pdf.close();
        baos.flush();
        byte[] result = baos.toByteArray();
        return new MCRByteContent(result);
    }

    @Override
    public String getMimeType() throws Exception {
        return "application/pdf";
    }

    @Override
    public String getFileExtension() throws Exception {
        return "pdf";
    }
}

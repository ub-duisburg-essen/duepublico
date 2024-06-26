package unidue.ub.duepublico;

import java.io.*;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;

import javax.xml.transform.TransformerException;

import org.apache.commons.io.FileUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.fdf.FDFDocument;
import org.apache.pdfbox.pdmodel.fdf.FDFField;
import org.apache.pdfbox.pdmodel.font.PDType0Font;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.interactive.form.PDAcroForm;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.output.DOMOutputter;
import org.mycore.common.MCRClassTools;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.*;
import org.mycore.common.content.transformer.MCRContentTransformer;
import org.mycore.frontend.MCRFrontendUtil;
import org.xml.sax.SAXException;

/**
 * Reads a PDF file from the /xfdf/f/@href specified in the given XFDF document,
 * fills the form fields with the XFDF document given as source input,
 * returns the resulting PDF.
 *
 * @author Frank L\u00FCtzenkirchen
 */
public class XFDF2PDFTransformer extends MCRContentTransformer {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final Namespace NS_XFDF = Namespace.getNamespace("xfdf", "http://ns.adobe.com/xfdf/");

    private static final String RELATIVE_FONT_PATH = "MCR.LayoutService.FoFormatter.FOP.FontSerifFilename";

    @Override
    public MCRContent transform(MCRContent source) throws IOException {
        MCRContent sourceXFDF = source.getReusableCopy();

        try {
            String href = getPDFHRef(sourceXFDF);

            MCRContent sourcePDF = MCRSourceContent.getInstance(href);
            PDDocument pdf = PDDocument.load(sourcePDF.getInputStream());

            PDType0Font font = addFontToPdf(pdf);

            PDAcroForm form = pdf.getDocumentCatalog().getAcroForm();
            form.setNeedAppearances(true);
            FDFDocument fdf = FDFDocument.loadXFDF(sourceXFDF.getInputStream());

            List<Character> unsupportedChars = getUnsupportedChars(fdf, font);

            if (!unsupportedChars.isEmpty()) {
                return getErrorContent(unsupportedChars);
            }

            form.importFDF(fdf);
            LOGGER.info("imported XFDF into PDF from " + href);

            MCRContent result = pdf2content(pdf);
            result.setMimeType(getMimeType());
            return result;
        } catch (JDOMException | TransformerException | SAXException | URISyntaxException ex) {
            throw new IOException(ex);
        }
    }

    private String getPDFHRef(MCRContent sourceXFDF) throws JDOMException, IOException, SAXException {
        Document doc = sourceXFDF.asXML();
        Element xfdf = doc.getRootElement();
        String href = xfdf.getChild("f", NS_XFDF).getAttributeValue("href");

        String baseURL = MCRFrontendUtil.getBaseURL();
        if (href.startsWith(baseURL)) {
            href = "webapp:" + href.substring(baseURL.length());
        }
        LOGGER.info("will read PDF from URI " + href);
        return href;
    }

    // Tried to use PDStream, but couldn't get it working
    private MCRContent pdf2content(PDDocument pdf) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        pdf.save(baos);
        pdf.close();
        baos.flush();
        byte[] result = baos.toByteArray();
        return new MCRByteContent(result);
    }

    /**
     * Returns a {@link MCRDOMContent} that displays an error message and lists the unsupported characters.
     * @param unsupportedChars a list of characters that are not supported by the current font.
     * @return the error message
     * @throws JDOMException in case of error in generating the document
     */
    private MCRContent getErrorContent(List<Character> unsupportedChars) throws JDOMException {

        Element xml = new Element("errorMessage");
        xml.addContent(new Element("message").setText("There are symbols used that cannot " +
            "be displayed in the PDF. Please use other symbol or contact the administrator"));
        for (char character : unsupportedChars) {
            xml.addContent(new Element("invalidSymbol").setText(String.valueOf(character)));
        }
        Document message = new Document(xml.clone());
        org.w3c.dom.Document w3doc = new DOMOutputter().output(message);
        return new MCRDOMContent(w3doc);
    }

    @Override
    public String getMimeType() {
        return "application/pdf";
    }

    @Override
    public String getFileExtension() {
        return "pdf";
    }

    /**
     * Returns a list of characters that are not supported by the current font for a given Document
     * @param fdf the FDFDocument containing all values to be tested
     * @param font the used {@link PDType1Font}
     * @return the list of unsupported characters or empty list if all characters are supported
     */
    private List<Character> getUnsupportedChars(FDFDocument fdf, PDType0Font font) throws IOException {
        List<Character> unsupported = new ArrayList<>();

        final List<FDFField> fields = fdf.getCatalog().getFDF().getFields();
        if (fields != null) {
            for (FDFField field : fields) {
                String text = field.getValue().toString();
                int offset = 0;
                while (offset < text.length()) {
                    int codePoint = text.codePointAt(offset);
                    int gid = font.codeToGID(codePoint);
                    if (gid == 0) {
                        unsupported.add(text.charAt(offset));
                    }
                    offset += Character.charCount(codePoint);
                }
            }
        }
        return unsupported;
    }

    /**
     * Loads the configured font and adds it to each page of the document.
     * @param pdf the document
     * @return the loaded font
     * @throws URISyntaxException in case of error while looking for the font resource
     * @throws IOException in case of error while loading the font
     */
    private PDType0Font addFontToPdf(PDDocument pdf) throws URISyntaxException, IOException {
        final String relativeFontPath = MCRConfiguration2.getString(RELATIVE_FONT_PATH).get();
        PDType0Font font = null;
        final InputStream fontInputStream = MCRClassTools.getClassLoader().getResourceAsStream(relativeFontPath);
        if (fontInputStream != null) {
            File file = new File(RELATIVE_FONT_PATH);
            FileUtils.copyInputStreamToFile(fontInputStream, file);
            fontInputStream.close();
            font = PDType0Font.load(pdf, file);
            for (PDPage page : pdf.getPages()) {
                page.getResources().add(font);
            }
        }
        return font;
    }
}

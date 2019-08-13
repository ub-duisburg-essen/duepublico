package unidue.ub.duepublico.ogesomo;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;

import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.DataFormat;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFFont;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

class ExcelReport {

    private final static String TARGET_FILE = "c:\\users\\frank\\desktop\\OGeSoMo-DuEPublico-Statistics.xlsx";

    private static final String WORKSHEET_TITLE = "Zugriffsstatistik";

    private static final String[] COLUMN_LABELS = { "ID", "Verlag", "Titel", "Autor", "Jahr", "DOI", "ISBN",
        "Zugriffe" };

    private XSSFWorkbook wb = new XSSFWorkbook();

    private XSSFSheet sheet = wb.createSheet(WORKSHEET_TITLE);

    private XSSFRow row;

    private CellStyle numberCell;

    private CellStyle textCell;

    private CellStyle headerCell;

    private int rowNumber = 0;

    private int colNumber = 0;

    ExcelReport(List<Publication> publications) throws FileNotFoundException, IOException {
        System.out.println("Building Excel report...");

        buildCellStyles();
        buildHeadline();
        buildColumnHeaderRow();

        for (Publication publication : publications) {
            nextRow();
            createCell(publication.id, textCell);
            createCell(publication.getPublisher(), textCell);
            createCell(publication.getTitle(), textCell);
            createCell(publication.getAuthor(), textCell);
            createCell(publication.getYear(), textCell);
            createCell(publication.getDOI(), textCell);
            createCell(publication.getISBN(), textCell);
            createCell("PDF Downloads", textCell);

            for (int year = Statistics.minYear; year <= Statistics.maxYear; year++) {
                for (int month = Statistics.getMinMonth(year); month <= Statistics.getMaxMonth(year); month++) {
                    createCell(publication.statistics.getNumAccess(Statistics.PDF_DOWNLOADS, year, month), numberCell);
                }
            }

            nextRow();
            colNumber += COLUMN_LABELS.length - 1;
            createCell("Landing Page", textCell);

            for (int year = Statistics.minYear; year <= Statistics.maxYear; year++) {
                for (int month = Statistics.getMinMonth(year); month <= Statistics.getMaxMonth(year); month++) {
                    createCell(publication.statistics.getNumAccess(Statistics.LANDING_PAGE, year, month), numberCell);
                }
            }
        }

        for (colNumber = 0; colNumber < COLUMN_LABELS.length; colNumber++) {
            sheet.autoSizeColumn(colNumber);
        }
    }

    private void buildCellStyles() {
        DataFormat fmt = wb.createDataFormat();

        numberCell = wb.createCellStyle();
        numberCell.setDataFormat(fmt.getFormat("0"));

        textCell = wb.createCellStyle();
        textCell.setDataFormat(fmt.getFormat("@"));

        XSSFFont headerFont = wb.createFont();
        headerFont.setBold(true);
        headerCell = wb.createCellStyle();
        headerCell.setDataFormat(fmt.getFormat("@"));
        headerCell.setFont(headerFont);
        headerCell.setBorderBottom(BorderStyle.THIN);
    }

    private void buildHeadline() {
        nextRow();
        String value = WORKSHEET_TITLE + " OGeSoMo DuEPublico " + Statistics.getRange();
        createCell(value, textCell);
        CellRangeAddress headline = new CellRangeAddress(0, 0, 0, 2);
        sheet.addMergedRegion(headline);
        rowNumber++;
    }

    private void buildColumnHeaderRow() {
        nextRow();

        for (; colNumber < COLUMN_LABELS.length;) {
            createCell(COLUMN_LABELS[colNumber], headerCell);
        }

        for (int year = Statistics.minYear; year <= Statistics.maxYear; year++) {
            for (int month = Statistics.getMinMonth(year); month <= Statistics.getMaxMonth(year); month++) {
                createCell(month + "/" + year, headerCell);
            }
        }
    }

    private void nextRow() {
        row = sheet.createRow(rowNumber++);
        colNumber = 0;
    }

    private XSSFCell nextCell(CellStyle style) {
        XSSFCell cell = row.createCell(colNumber++);
        cell.setCellStyle(style);
        return cell;
    }

    private void createCell(String value, CellStyle style) {
        nextCell(style).setCellValue(value);
    }

    private void createCell(int value, CellStyle style) {
        nextCell(style).setCellValue(value);
    }

    void save() throws FileNotFoundException, IOException {
        System.out.println("Saving Excel report to " + TARGET_FILE + " ...");
        FileOutputStream fileOut = new FileOutputStream(TARGET_FILE);
        wb.write(fileOut);
        wb.close();
        fileOut.flush();
        fileOut.close();
    }
}

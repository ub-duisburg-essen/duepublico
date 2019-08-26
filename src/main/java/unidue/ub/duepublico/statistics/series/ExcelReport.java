package unidue.ub.duepublico.statistics.series;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.DataFormat;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFFont;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

public class ExcelReport implements Report {

    private final static Logger LOGGER = LogManager.getLogger(ExcelReport.class);

    private static final String[] COLUMN_LABELS = { "ID", "Verlag", "Titel", "Autor", "Jahr", "DOI", "ISBN",
        "Zugriffe" };

    private XSSFWorkbook wb = new XSSFWorkbook();

    private XSSFSheet sheet;

    private XSSFRow row;

    private CellStyle numberCell;

    private CellStyle textCell;

    private CellStyle headerCell;

    private int rowNumber = 0;

    private int colNumber = 0;

    private String target;

    private String worksheetTitle;

    private StatisticDates statisticDates;

    public ExcelReport(List<Publication> publications, StatisticDates statisticDates,
        String target, String filename) throws FileNotFoundException, IOException {

        this.target = target;
        this.sheet = wb.createSheet(filename);

        this.worksheetTitle = filename;

        this.statisticDates = statisticDates;

        LOGGER.info("Building Excel report...");

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

            LOGGER.info("Cells created in row with the following informations: " + publication.id + "; "
                + publication.getPublisher() + "; "
                + publication.getTitle() + "; "
                + publication.getAuthor() + "; "
                + publication.getYear() + "; "
                + publication.getDOI() + "; "
                + publication.getISBN() + "; ");

            for (int year = statisticDates.getMinYear(); year <= statisticDates.getMaxYear(); year++) {
                for (int month = statisticDates.getMinMonthForYear(year); month <= statisticDates
                    .getMaxMonthForYear(year); month++) {
                    createCell(publication.getStatistics().getNumAccess(Statistics.PDF_DOWNLOADS, year, month),
                        numberCell);
                    LOGGER.info("Cell created for pdf download statistics with id " + publication.id + ", " + year
                        + " - " + month + ": " + Statistics.PDF_DOWNLOADS + "; ");
                }
            }

            nextRow();
            colNumber += COLUMN_LABELS.length - 1;
            createCell("Landing Page", textCell);

            for (int year = statisticDates.getMinYear(); year <= statisticDates.getMaxYear(); year++) {
                for (int month = statisticDates.getMinMonthForYear(year); month <= statisticDates
                    .getMaxMonthForYear(year); month++) {
                    createCell(publication.getStatistics().getNumAccess(Statistics.LANDING_PAGE, year, month),
                        numberCell);
                    LOGGER.info("Cell created for landing page statistics with id " + publication.id + ", " + year
                        + " - " + month + ": " + Statistics.PDF_DOWNLOADS + "; ");
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
        String value = this.worksheetTitle + " " + statisticDates.getRange();
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

        for (int year = this.statisticDates.getMinYear(); year <= this.statisticDates.getMaxYear(); year++) {
            for (int month = this.statisticDates.getMinMonthForYear(year); month <= this.statisticDates
                .getMaxMonthForYear(year); month++) {
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

    public void save() throws FileNotFoundException, IOException {
        LOGGER.info("Saving Excel report to " + this.target + this.worksheetTitle + "...");
        FileOutputStream fileOut = new FileOutputStream(this.target + this.worksheetTitle);
        wb.write(fileOut);
        wb.close();
        fileOut.flush();
        fileOut.close();
    }
}

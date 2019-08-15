package unidue.ub.duepublico.statistics.series;

import org.jdom2.Element;

class Publication {

    String id;

    Element metadata = null;

    Statistics statistics = null;

    Publication(String id, Element metadata, Statistics statistics) throws Exception {
        this.id = id;
        this.metadata = metadata;
        this.statistics = statistics;
    }

    String getPublisher() {
        return XPaths.get(metadata, "publisher", null, "");
    }

    int getYear() {
        String y = XPaths.get(metadata, "year", null, "0000");
        if (y.length() < 4)
            y = "0000";
        return Integer.parseInt(y.substring(0, 4));
    }

    String getTitle() {
        return XPaths.get(metadata, "title", null, "");
    }

    String getAuthor() {
        return XPaths.get(metadata, "author", ", ", "");
    }

    String getDOI() {
        return XPaths.get(metadata, "doi", null, "");
    }

    String getISBN() {
        return XPaths.get(metadata, "isbn", ", ", "");
    }
}

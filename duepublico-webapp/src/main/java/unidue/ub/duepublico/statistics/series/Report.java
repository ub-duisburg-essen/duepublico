package unidue.ub.duepublico.statistics.series;

import java.io.FileNotFoundException;
import java.io.IOException;

public interface Report {

    default void save() throws FileNotFoundException, IOException {
    }
}

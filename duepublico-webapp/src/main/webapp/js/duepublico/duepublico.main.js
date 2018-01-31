/**
 * @author Paul Rochowski
 */
$(document).ready(function () {

    if (this.URL.startsWith(webApplicationBaseURL + 'receive/')) {

        console.log("bind statistics");

        var $systemPanel = $("#main_content #aux_col");
        let templateStatistics = `
        <div class="panel panel-default" id="duepublico_statistics">
        
            <div class="panel-heading">
                <h3 class="panel-title">Zugriffsstatistik</h3>
        
            </div>
            <div class="panel-body">
        
                <strong>Zugriffsstatistiken für DuEPublico sind ab Monat 12/2004 verfügbar.</strong>
        
                <p style="margin-top: 30px;">Zeitraum wählen</p>
                <p> Von: </p>
        
                <div class="form-inline controls">
                    <select class="form-control form-control-inline">
                        <option title="Januar" value="ar">Januar</option>
                        <option title="Februar" value="bs">Februar</option>
                        <option title="März" value="bg">März</option>
                        <option title="April" value="zh">April</option>
                        <option title="Mai" value="da">Mai</option>
                        <option title="Juni" value="en">Juni</option>
                        <option title="Juli" value="fi">Juli</option>
                        <option title="August" value="fr">August</option>
                        <option title="September" value="el">September</option>
                        <option title="Oktober" value="heb">Oktober</option>
                        <option title="November" value="nl">November</option>
                        <option title="Dezember" value="id">Dezember</option>
                    </select>
                    <select class="form-control form-control-inline">
                        <option title="2004" value="2004">2004</option>
                        <option title="2005" value="2005">2005</option>
                        <option title="2006" value="2006">2006</option>
                        <option title="2007" value="2007">2007</option>
                        <option title="2008" value="2008">2008</option>
                        <option title="2009" value="2009">2009</option>
                        <option title="2010" value="2010">2010</option>
                        <option title="2011" value="2011">2011</option>
                        <option title="2012" value="2012">2012</option>
                        <option title="2013" value="2013">2013</option>
                        <option title="2014" value="2014">2014</option>
                        <option title="2015" value="2015">2015</option>
                        <option title="2016" value="2016">2016</option>
                        <option title="2017" value="2017">2017</option>
                    </select>
                </div>
        
                <p style="margin-top: 30px;"> Bis: </p>
                <div class="form-inline controls">
                    <select class="form-control form-control-inline">
                        <option title="Dezember" value="id">Dezember</option>
                    </select>
                    <select class="form-control form-control-inline">
                        <option title="2017" value="2017">2017</option>
                    </select>
                </div>
                <div style="margin-top: 45px;">
                    <a style="cursor: pointer" id="statisticsStarter">Statistik anzeigen</a>
                </div>
            </div>
        </div>`;

        $($systemPanel).append(templateStatistics);
    }
});
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
        
                <p style="text-align: center;margin-top: 30px;">Zeitraum wählen:</p>
        
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
                </div>
            </div>
        </div>
        `;

        $($systemPanel).append(templateStatistics);
    }
});
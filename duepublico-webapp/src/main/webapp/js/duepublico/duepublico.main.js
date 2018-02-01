/**
 * @author Paul Rochowski
 */
$(document).ready(function () {

    var vm = this;

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
                    <select class="form-control form-control-inline" id="statisticsFromMonth">
                        <option title="1" value="1">1</option>
                        <option title="2" value="2">2</option>
                        <option title="3" value="3">3</option>
                        <option title="4" value="4">4</option>
                        <option title="5" value="5">5</option>
                        <option title="6" value="6">6</option>
                        <option title="7" value="7">7</option>
                        <option title="8" value="8">8</option>
                        <option title="9" value="9">9</option>
                        <option title="10" value="10">10</option>
                        <option title="11" value="11">11</option>
                        <option title="12" value="12">12</option>
                    </select>
                    <select class="form-control form-control-inline" id="statisticsFromYear">
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
                    <select class="form-control form-control-inline" id="statisticsToMonth">
                        <option title="1" value="1">1</option>
                        <option title="2" value="2">2</option>
                        <option title="3" value="3">3</option>
                        <option title="4" value="4">4</option>
                        <option title="5" value="5">5</option>
                        <option title="6" value="6">6</option>
                        <option title="7" value="7">7</option>
                        <option title="8" value="8">8</option>
                        <option title="9" value="9">9</option>
                        <option title="10" value="10">10</option>
                        <option title="11" value="11">11</option>
                        <option title="12" value="12">12</option>
                    </select>
                    <select class="form-control form-control-inline" id="statisticsToYear">
                        <option title="2017" value="2017">2017</option>
                    </select>
                </div>
                <div style="margin-top: 45px;">
                    <a style="cursor: pointer" id="statisticsStarter">Statistik anzeigen</a>
                </div>
            </div>
        </div>
`;

        $($systemPanel).append(templateStatistics);

        /**
         * show full version of statistics
         */
        function getStatistics() {
            /*
             * evaluate from / to dates
             */
            var statisticsFromMonth = $("#statisticsFromMonth option:selected").text();
            var statisticsFromYear = $("#statisticsFromYear option:selected").text();

            var statisticsToMonth = $("#statisticsToMonth option:selected").text();
            var statisticsToYear = $("#statisticsToYear option:selected").text();

            var documentId = vm.baseURI.split(webApplicationBaseURL + "receive/")[1];

            var statisticsUrl = webApplicationBaseURL + 'servlets/StatisticsServlet/'
                + documentId
                + '?fromMonth=' + statisticsFromMonth
                + '&fromYear=' + statisticsFromYear
                + '&toMonth=' + statisticsToMonth
                + '&toYear=' + statisticsToYear;


            console.log("duepublico.main.js - getStatistics: do Ajax Request to URL " + statisticsUrl);


            $.ajax({
                url: statisticsUrl,
                type: "GET",
                success: function (data) {

                    console.log(data);
                },
                error: function (error) {
                    console.log("duepublico.main.js - getStatistics: Failed ajax GET request to URL " + statisticsUrl);
                    console.log(error);
                }
            });
        }

        $("#statisticsStarter").click(getStatistics);
    }
});
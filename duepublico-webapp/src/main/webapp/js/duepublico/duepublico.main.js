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

                        /*
                         * transform LoggedDocument
                         *
                         *
                         * to do
                         * <object type="document" id="44914">
                         * <num year="2017" month="08">0</num>
                         * <num year="2017" month="09">0</num>
                         * <num year="2017" month="10">0</num>
                         * <num year="2017" month="11">50</num>
                         * <num year="2017" month="12">4</num>
                         * <num year="2018" month="01">6</num>
                         * <object type="derivate" id="44384">
                         *
                         *data: [[Date.UTC(2017, 7, 1), 0],
                         *[Date.UTC(2017, 8, 1), 0],
                         *[Date.UTC(2017, 9, 1), 0],
                         *[Date.UTC(2017, 10, 1), 63],
                         *[Date.UTC(2017, 11, 1), 7],
                         *[Date.UTC(2018, 0, 1), 6],]
                         *
                         */

                        /*
                         * Dokument insgesamt -> Dokument 'id'.value + insgesamt
                         */
                        let loggedDocuments = [];

                        const DAY_STATISTICS = 1;

                        var mapTotalDerivatesAccess = new Map();
                        var mapTotalDocumentAccess = new Map();


                        $(data).find("object").each(function () {


                            var currentObject = this;
                            var attributesCurrentObj = {};

                            $.each(currentObject.attributes, function (index, attrib) {

                                attributesCurrentObj[attrib.name] = attrib.value;

                            });

                            /*
                             * look at whole num section of derivate + total document
                             */
                            $(currentObject).find("num").each(function () {

                                var currrentNum = this;
                                var attributesNum = {};


                                $.each(currrentNum.attributes, function (index, attrib) {

                                    attributesNum[attrib.name] = attrib.value;

                                });

                                let year = attributesNum.year;
                                let month = attributesNum.month;

                                let access = parseInt(currrentNum.textContent);

                                if (attributesCurrentObj.type !== "document") {


                                    mapTotalDerivatesAccess.set(Date.UTC(year, month, DAY_STATISTICS), access);
                                }

                                mapTotalDocumentAccess.set(Date.UTC(year, month, DAY_STATISTICS), access);
                            });
                            

                            // /*
                            //  * document section
                            //  */
                            // if (attributesCurrentObj.type === "document") {
                            //
                            //     var documentTotal = 'Dokument ' + attributesCurrentObj.id + ' insgesamt';
                            //
                            //     $(documentNumSection).find("num").each(function () {
                            //
                            //         var documentSection = this;
                            //         var documentDates = [];
                            //
                            //         var attributesDocumentTime = {};
                            //
                            //         $.each(documentSection.attributes, function (index, attrib) {
                            //
                            //             attributesDocumentTime[attrib.name] = attrib.value;
                            //
                            //         });
                            //
                            //         const DAY_STATISTICS = 1;
                            //
                            //         let year = attributesDocumentTime.year;
                            //         let month = attributesDocumentTime.month;
                            //         //let access = this.text();
                            //
                            //         documentDates.push([Date.UTC(year, month, DAY_STATISTICS), "access"])
                            //     });
                            //
                            //
                            //     console.log('duepublico.main.js - getStatistics:' + documentTotal);
                            // }


                            // if (this.attr("type") === "document") {
                            //
                            //     var documentTotal = 'Dokument ' + this.attr('id') + ' insgesamt';
                            //
                            //     $(this).find('num').each(function () {
                            //
                            //         const DAY_STATISTICS = 1;
                            //
                            //         let year = this.attr('year');
                            //         let month = this.attr('month');
                            //         let access = this.text();
                            //
                            //
                            //         var dateCurrent = [Date.UTC(year, month, DAY_STATISTICS), access];
                            //
                            //         loggedDocuments.push(dateCurrent);
                            //
                            //         //[[Date.UTC(2017,4, 1), 6],[Date.UTC(2017,5, 1), 7],[Date.UTC(2017,6, 1), 22],[Date.UTC(2017,7, 1), 4],]
                            //
                            //     });
                            // }
                            //
                            // var objectType = this;
                            //
                            //
                            //
                            // type = document
                            //
                            // console.log(objectType);
                        });

                    }

                    ,
                    error: function (error) {
                        console.log("duepublico.main.js - getStatistics: Failed ajax GET request to URL " + statisticsUrl);
                        console.log(error);
                    }
                }
            );
        }

        $("#statisticsStarter").click(getStatistics);
    }
});
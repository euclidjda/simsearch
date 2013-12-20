
function draw_detail_chart( cid, sid, pricedate) {

        var json_data = get_price_data(cid, sid, pricedate);
        var nSeries = new Array();
        var dateSeries = new Array();
        var nMarket = new Array();  //market price series, just to calculate the 
        var seriesBegin = 0;

        // Walk through the price data, correct any missing market (S&P 500) price, find the data date and 
        // populate the series we will use to draw the graph.
        var i;
        var maxGain = 0, minGain = 0;
        for (i=0; i < json_data.length; i++) {

            if (json_data[i].mrk_price == null || json_data[i].mrk_price == 0) {
                if (i>0)
                    json_data[i].mrk_price = json_data[i-1].mrk_price;
            }

            if (json_data[i].datadate == pricedate) {
                seriesBegin = i;
            }

            if (seriesBegin > 0) {

                var seriesEntry;
                seriesEntry = (json_data[i].price * json_data[seriesBegin].ajex) / (json_data[seriesBegin].price * json_data[i].ajex);
                seriesEntry -= json_data[i].mrk_price / json_data[seriesBegin].mrk_price;

                maxGain = Math.max(maxGain, seriesEntry);
                minGain = Math.min(minGain, seriesEntry);

                nSeries.push(seriesEntry);
                dateSeries.push(json_data[i].datadate);
            }
        }

        // Get comparable set values.
        var search_id = $("#search_id_cache").text();
        var summary_data = get_search_summary_data(search_id);

        // Market range, calculated from the max and min return of the comparable result set.
        var setMax = summary_data.max / 100;
        var setMin = summary_data.min / 100;

        // Find the all-inclusive range.
        var rangeMax = Math.max(maxGain, setMax);   // pick the maximum of the comparable data set and the specific comparable
        var rangeMin = Math.min(minGain, setMin);   // same as max, for the min this time.
        rangeMax += rangeMax / 5;
        rangeMin += rangeMin / 5;

        // define dimensions of graph
        var m = [40, 90, 80, 80]; // margins
        var w = 900 - m[1] - m[3];  // width
        var h = 400 - m[0] - m[2]; // height
        
        // create a simple data array that we'll plot with a line (this array represents only the Y values, X will just be the index location)
        // data2 and data3 are the linear lines that are derived based      

        var data2 = [];
        var data3 = [];
        var data4 = [];
        var setRange = setMax - setMin;

        for (i=0; i < nSeries.length; i++) {
            data2[i] = i * (setMax / nSeries.length);
            data3[i] = i * (setMin / nSeries.length);
            data4[i] = 0;   // S&P 500  is the base.
        }

        // X scale will fit all values from data[] within pixels 0-w
        var x = d3.scale.linear().domain([0, nSeries.length - 1]).range([0, w]);

        // Y scale will fit values from 0-10 within pixels h-0 (Note the inverted domain for the y-scale: bigger is up!)
        var yScale = d3.scale.linear().domain([rangeMin, rangeMax]).range([h, 0]); // in real world the domain would be dynamically calculated from the data
        // automatically determining max range can work something like this
        // var y = d3.scale.linear().domain([0, d3.max(data)]).range([h, 0]);   


        // create a single object for the background fill.
        var fillData = data2.map(function(d, i) { 
            return { x: i, y0: yScale(data3[i]) , y1: yScale(d)}; });       

        // create a line function that can convert data[] into x and y points
        var line1 = d3.svg.line()
            // assign the X function to plot our line as we wish
            .x(function(d,i) { 
                // return the X coordinate where we want to plot this datapoint
                return x(i); 
            })
            .y(function(d) { 
                // return the Y coordinate where we want to plot this datapoint
                return yScale(d); 
            })

        var indexes = d3.range(fillData.length);

        var fillArea = d3.svg.area()
          .x(function(d) { return x(d.x); })
          .y0(function(d) { return d.y0; })
          .y1(function(d) { return d.y1; });            

        var svgWidth = w + m[1] + m[3];
        var svgHeight = h + m[0] + m[2];

        // Add an SVG element with the desired dimensions and margin.
        var graph = d3.select("#detail-graph")
            .append("svg:svg")
              .attr("width", svgWidth)
              .attr("height", svgHeight)
              .attr("viewBox", "0 0 " + svgWidth + " " + svgHeight)
              .attr("preserveAspectRatio", "xMidYMid")
            .append("svg:g")
              .attr("transform", "translate(" + m[3] + "," + m[0] + ")");

        var aspect = svgWidth/svgHeight,
            theGraph = d3.select("svg");

        window.onresize =  function() {
                var targetWidth = $("#detail-graph").width();
                theGraph.attr("width", targetWidth);
                theGraph.attr("height", targetWidth / aspect);
            };            


        // Create month
        var formatter = new Intl.DateTimeFormat("en-us", { month: "short" });
        var xAxisLabels = new Array();

        var startDate = new Date(dateSeries[0]);
        var startDateText = formatter.format(startDate) + " " + startDate.getDate() + "," + (startDate.getYear() + 1900)        

        var currentMonth = "";
        var newMonth = "";

        var formatXTick = function(d) {
            d = Math.ceil(d);
            dt = new Date(dateSeries[d]);
            newMonth = formatter.format(dt);

            if (newMonth == currentMonth) {
                return "";
            }
            else {
                if (currentMonth == "") {
                    currentMonth = newMonth;
                    return startDateText;
                }
                else {
                    currentMonth = newMonth;
                    if (currentMonth == "Jan") {
                        return dateSeries[d].substring(0,4);
                    }
                    else {
                        return currentMonth;
                    }
                }
            }

            return "";
        }

        var formatYTick = function(d) {
            return sprintf("%.0f%%",100*d);
        }

        // create xAxis
        var xAxis = d3.svg.axis().scale(x).ticks(nSeries.length).tickSize(-h).tickSubdivide(true).tickFormat(formatXTick);

        // Add the x-axis.
        graph.append("svg:g")
              .attr("class", "x axis")
              .attr("transform", "translate(0," + (h) + ")")
              .call(xAxis)
              .selectAll("text")  
                    .style("text-anchor", "end")
                    .attr("dx", "-.18em")
                    .attr("dy", ".15em")
                    .attr("transform", function(d) {
                    return "rotate(-65)" 
                });

        // create left yAxis
        var yAxisLeft = d3.svg.axis().scale(yScale).ticks(5).tickSize(-w).orient("left").tickFormat(formatYTick);

        // Add the y-axis to the left
        graph.append("svg:g")
              .attr("class", "y axis axisLeft")
              .attr("transform", "translate(0,0)")
              .call(yAxisLeft);
        
        // add lines
        // do this AFTER the axes above so that the line is above the tick-lines

        graph.append("svg:path").attr("d", line1(nSeries)).attr("class", "data1");
        graph.append("svg:path").attr("d", line1(data2)).attr("class", "data2");
        graph.append("svg:path").attr("d", line1(data3)).attr("class", "data3");

        // paint between two lines for highlight
        graph.append("path")
              .datum(fillData)
              .attr("class", "area")
              .attr("d", fillArea);         

        // add X axis legend
        graph.append("text")      // text label for the x axis
            .attr("x", w/2 )
            .attr("y", h + 64 )
            .style("text-anchor", "middle")
            .text("Date");

        // add Y axis legend
        graph.append("text")
            .attr("x", -h + 10)
            .attr("y", -64 )
            .style("text/anchor", "middle")
            .text("Performance Relative to S&P 500")
            .attr("transform", function(d) { return "rotate(-90)" });

        // add best/worst comparable legend markers
        graph.append("text")
            .attr("x", w + 5)
            .attr("y", yScale(data2[nSeries.length -1]))
            .style("text/anchor", "right")
            .text("Best Comp")

        graph.append("text")
            .attr("x", w + 5)
            .attr("y", yScale(data2[nSeries.length -1]) + 14)
            .style("text/anchor", "right")
            .text(sprintf("%.2f%%",100*setMax))            

        graph.append("text")
            .attr("x", w + 5)
            .attr("y", yScale(data3[nSeries.length -1]) + 14)
            .style("text/anchor", "right")
            .text("Worst Comp")

        graph.append("text")
            .attr("x", w + 5)
            .attr("y", yScale(data3[nSeries.length -1]) + 28)
            .style("text/anchor", "right")
            .text(sprintf("%.2f%%",100*setMin))                

        // add the actual ticker legend and return.
        graph.append("text")
            .attr("x", w + 3)
            .attr("y", yScale(nSeries[nSeries.length - 1]))
            .style("text/anchor", "right")
            .text($("#comp_ticker").text() + " " + sprintf("%.2f%%", nSeries[nSeries.length - 1]*100));       

        // Add graph title
        graph.append("text")
            .attr("x", 80)
            .attr("y", -15)
            .style("text/anchor", "right")
            .attr("font-size", "14pt")
            .text("1 Year Relative Performance of " + $("#comp_ticker").text() + " Starting on " + startDateText);

        // S&P 500 line and marker
        graph.append("svg:path")
            .attr("class", "data4")
            .style("stroke-dasharray", ("5, 5"))            
            .attr("d", line1(data4));            

        graph.append("text")
            .attr("x", w - 55)
            .attr("y", yScale(nSeries[0]) - 4)
            .style("text/anchor", "right")
            .text("S&P 500");
}

function get_price_data( cid, sid, pricedate ) {
    
    var post_data = {'cid':cid,'sid':sid,'pricedate':pricedate};
    var json_data = null;

    $.ajax({
        url:      'get_price_time_series',
        dataType: 'json',
        async:    false,
        data:     post_data,
        success:  function(data) {
            json_data = data;
        }
    });

    return json_data;
}

function get_search_summary_data(search_id) {

    var post_data = { 'search_id':search_id};
    var json_data = null;

    $.ajax({
        url: 'get_search_summary',
        dataType: 'json',
        async: false,
        data: post_data,
        success: function(data) {
            json_data = data;
        }
    });

    return json_data;
}
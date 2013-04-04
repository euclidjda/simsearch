var pos_small_icon = "assets/green-outperformance-small.png";
var neg_small_icon = "assets/red-outperformance-small.png";
var pos_big_icon   = "assets/green-outperformance-small.png";
var neg_big_icon   = "assets/red-outperformance-small.png";

function render_results(search_id) {

    $('.result-container').each(function( index ) {

        start_spinner($(this).attr('id'));

        var fromdate = $(this).attr('fromdate');
        var thrudate = $(this).attr('thrudate');

        var post_data = new Object();
        post_data['search_id'] = search_id;
        post_data['fromdate'] = fromdate;
        post_data['thrudate'] = thrudate;

        var this_obj = $(this);

        // set the URL of the page to the search_id so we can see it nice and clean.
        // window.history.replaceState( {}, 
        //     "Euclidean Fundamentals Search ID " + search_id, 
        //     "/search?search_id=" + search_id);

        (function poll_for_result() {

            $.getJSON('get_search_results',post_data,function(json_data) {

                this_obj.find(".spinner").remove();
                this_obj.find(".bxslider").empty();
                var search_status = this_obj.find(".search-status");

                if (json_data != null) {
                    
                    if (json_data.comment != null) {
                        start_spinner(this_obj.attr('id'));
                        $(search_status).css("display","inline-block");
                        $(search_status).text(json_data.comment);
                        setTimeout(poll_for_result,1000);

                    } else if (json_data.length) {
                        $(search_status).css("display", "none");
                        var max_panels = json_data.length;

                        for (var i=0; i < max_panels; i++) {
                            populate_panels(this_obj,json_data,i);
                        }

                        this_obj.find(".bxslider").bxSlider({
                            minSlides:1, 
                            maxSlides:4, 
                            moveSlides: 1,
                            slideWidth: 240, 
                            slideMargin: 10,
                            pager: true,
                            hideControlOnEnd: true,
                            infiniteLoop: false
                        });
                    } else {

                        this_obj.html("<div class='no-results-found'>"+
                           "No comparables found for this period.</div>");
                    }
                }
            });

        })();
    });

    (function poll_for_summary() {

        $.getJSON('get_search_summary?search_id='+search_id,function(data) {

            var perf  = data.mean;

            if (perf == null) {
                $(".summary-num").html("N/A");
            } else if (perf >= 0) {
                $(".summary-image").attr("src",pos_big_icon);
                $(".summary-num").html(sprintf("%.2f%%",perf));
                $(".summary-num").css('color','black');
                $(".summary-label").html("Outperformed");
            } else {
                $(".summary-image").attr("src",neg_big_icon);
                $(".summary-num").html(sprintf("%.2f%%",perf));
                $(".summary-num").css('color','red');
                $(".summary-label").html("Underperformed");
            }

            $("#summary-worst")
                .html(EGUI.fmtAsNumber(data.min,{fmtstr:"%.2f%%"}));

            $("#summary-best")
                .html(EGUI.fmtAsNumber(data.max,{fmtstr:"%.2f%%"}));

            if( data.min < 0) $("#summary-worst").css('color','red');
            if( data.max  < 0) $("#summary-best").css('color','red');

            if ((data.count != null) && (data.wins != null)) {
            
            $('#summary-count')
                .html(data.wins + ' of ' + data.count);
        }

        if (!data.complete)
            setTimeout(poll_for_summary,3000);
        });

    })();

    setup_detail_modal();
}

function populate_panels(row_obj,data,i) {

    var year = data[i].pricedate.substring(0,4);
    var row = get_row_from_year(year);
    var col = i;

    // clone the invisible template and drop data into clone
    panel = $('#comparable-panel-template').clone();
    panel.attr('id','panel'+i);
    panel.hover(function(){ $(this).addClass('comparable-hover') },
	        function(){ $(this).removeClass('comparable-hover') } );

    // TODO: JDA Not sure the best way to truncate the string here
    // we really just want it to not flow over the panel
    var panel_name = panel.find('.panel-name');
    panel_name.html(data[i].name);
    panel_name.tooltip({
      placement: 'bottom',
      title: 'Click to see detailed factor comparison to ' + data[i].name,
      container: "body"
    }); 
    panel_name.click(function() {

        $('#comparable-modal').modal('show');
        var idx = 10 * row + col;

        $('#comparable-carousel-right').carousel(idx);
    });

    var ticker = data[i].ticker;
    var exchg  = exchange_code_to_name(data[i].exchg,ticker);

    panel.find('.panel-ticker').html(exchg+': '+ticker);

    var dd = new Date(data[i].pricedate);

    var datearr = dd.toDateString().split(" ");
    var datestr = datearr[1] + " " + datearr[2] + ", " + datearr[3];

    panel.find('.panel-date').html(datestr);

    // calc outperformance
    var perf = data[i].stk_rtn - data[i].mrk_rtn;

    if (perf >= 0) {
        panel.find(".perf-image").attr("src",pos_small_icon);
        panel.find(".perf-num").html(sprintf("%.2f%%",perf));
        panel.find(".perf-tag").html("1 Yr Rtn <br><u>Above</u> Mrkt");
    } else {
        panel.find(".perf-image").attr("src",neg_small_icon);
        panel.find(".perf-num").html(sprintf("%.2f%%",perf));
        panel.find(".perf-tag").html("1 Yr. Rtn <br><u>Below</u> Mrkt");
    }

    var sim_score = sprintf("%.2f",
                            (100 * Math.exp(-(data[i].distance))));

    panel.find('.panel-similarity')
        .html('Similarity Score: '+ sim_score);

    // show makes the panel visible (the template from which it
    // was cloned was invisible)
    panel.show();


    // This packs  the panel into the DOM so it can be seenn
    var theList = $(row_obj).find("ul");
    var listItem = document.createElement("li");
    $(theList).append(listItem);
    $(listItem).append(panel);

    // Add to detailed compare
    var detail_item = $('#carousel-item-right-template').clone();

    var detail_item_id = 'carousel-item-right-' + row + '-' + i;

    detail_item.attr('id',detail_item_id);
    detail_item.attr('cid',data[i].cid);
    detail_item.attr('sid',data[i].sid);
    detail_item.attr('pricedate',data[i].pricedate);

    detail_item.removeAttr('style');

    detail_item.find('.company-name').html(data[i].name);

    detail_item.find('.ticker').html('<b>'+exchg+'</b>: '+ticker);

    detail_item.find('.year').html(datearr[3]);

    detail_item.find('.date').html(datestr);

    detail_item.find('.mrkcap-value').html(
        EGUI.fmtAsNumber(data[i].mrkcap,{fmtstr:"%.0f"})+'M');

    detail_item.find('.price-value').html(
        EGUI.fmtAsMoney(data[i].price,{fmtstr:"%.2f"}));

    detail_item.find('.dividend-value')
        .html(EGUI.fmtAsMoney(data[i].dvpsxm_ttm,
                              {fmtstr:"%.2f"}) + " ("+
              EGUI.fmtAsNumber(data[i].yield*100,
                               {fmtstr:"%.1f%%"})+")");
    detail_item.find('.eps-value').html(
        EGUI.fmtAsMoney(data[i].epspxq_ttm,{fmtstr:"%.2f"}));

    detail_item.find('.pe-value').html(
        EGUI.fmtAsMoney(data[i].pe,{fmtstr:"%.2f"}));

    detail_item.find('.pb-value').html(EGUI.fmtAsMoney(data[i].pb,
                               {fmtstr:"%.2f"}));

    detail_item.find('.factor-ey').html(
        EGUI.fmtAsNumber(data[i].ey*100,{fmtstr:"%.2f"}));


    detail_item.find('.factor-roc')
        .html(EGUI.fmtAsNumber(data[i].roc*100,{fmtstr:"%.2f%%"}));


    detail_item.find('.factor-grwth')
        .html(EGUI.fmtAsNumber(data[i].grwth*100,{fmtstr:"%.2f%%"}));

    detail_item.find('.factor-epscon')
        .html(EGUI.fmtAsNumber(data[i].epscon,{fmtstr:"%.2f"}));


    detail_item.find('.factor-ae')
        .html(EGUI.fmtAsNumber(data[i].ae*100,{fmtstr:"%.2f%%"}));

    detail_item.find('.factor-momentum')
        .html(EGUI.fmtAsNumber(data[i].mom*100,{fmtstr:"%.2f%%"}));

    detail_item.find('.similarity-score')
        .html(EGUI.fmtAsNumber(sim_score,{fmtstr:"%.2f"}));

    var growth_chart_id = 'chart-growth-'+detail_item_id;
    detail_item.find('.chart-growth').attr('id',growth_chart_id);

    var price_chart_id = 'chart-price-'+detail_item_id;
    detail_item.find('.chart-price').attr('id',price_chart_id);

    if (!i && !row) detail_item.addClass('active');

    $('#carousel-inner-right').append(detail_item);

}

function setup_detail_modal() {

    $('#comparable-carousel-right').bind('slid', function() {

        $('#comparable-carousel-right').carousel('pause');
        draw_charts('right');
    });

    $('#comparable-modal').bind('shown', function() {

        $('#comparable-carousel-right').carousel('pause');
        draw_charts('left');
        draw_charts('right');

    });
}

function draw_charts(side) {

    if (side == null) side = 'right';

    var active_item = $('#carousel-inner-'+side+' .item.active');
    var growth_chart_id = active_item.find('.chart-growth').attr('id');
    var price_chart_id = active_item.find('.chart-price').attr('id');

    var cid = active_item.attr('cid');
    var sid = active_item.attr('sid');
    var pricedate = active_item.attr('pricedate');

    // alert("cid="+cid+" sid="+sid+" pricedate="+pricedate);

    if (!active_item.hasClass('charts-drawn')) {

        draw_growth_chart( cid, sid, pricedate, growth_chart_id, side );

        draw_price_chart( cid, sid, pricedate, price_chart_id, side );

        active_item.addClass('charts-drawn');
    }

}

function draw_growth_chart( cid, sid, pricedate, growth_chart_id, side ) {

    var post_data = {'cid':cid,'sid':sid,'pricedate':pricedate};
    var json_data = null;

    $.ajax({
        url:      'get_growth_time_series',
        dataType: 'json',
        async:    false,
        data:     post_data,
        success:  function(data) {
            json_data = data;
        }
    });

   // This we will get by snycronous ajax request with cid,sid,datadate
    var revenue = Array(); //[80,120,115,130];
    var gain    = Array(); //[0,11,12,14];
    var loss    = Array(); //[14,0,0,0];

    var x_axis_labels = Array(); //['2002','2003','2004','2005'];


    for (var i=0; i < json_data.length; i++) {

        var idx = json_data.length-i-1;

        revenue[idx] = json_data[i].sale;

        var profit = json_data[i].opi;

        gain[idx] = (profit >= 0) ? profit : 0;
        loss[idx] = (profit <  0) ? -profit : 0;

        x_axis_labels[idx] = json_data[i].datadate.substring(0,4);

    }

    var series_data = [
        {label:'Revenue',color:'#56617F'},
        {label:'Operating-Income',color:'#7C8FB7'},
        {label:'Operating-Loss',color:'red'}
    ];

    $.jqplot(growth_chart_id,[revenue,gain,loss],
             {
                 fontFamily: 'Helvetica',

                 title: {
                     text: 'Historical Growth',
                     fontFamily: 'Helvetica',
                     textAlign: 'left',
                 },
                 stackSeries: true,
                 seriesDefaults:{
                     renderer:$.jqplot.BarRenderer,
                     shadow: false,
                     rendererOptions: {
                         barMargin: 30,
                     }
                 },
                 series: series_data,
                 grid: {
                     background: '#F2F2F2',
                     shadow: false,
                 },
                 legend: {
                     show: true,
                     location: 'nw',
                     xoffset: 0,
                     yoffset: 0
                 },
                 axes: {
                     xaxis: {
                         renderer: $.jqplot.CategoryAxisRenderer,
                         ticks: x_axis_labels
                     },
                     yaxis: {
                         pad: 1.05,
                         tickOptions: {formatString: '$%dM'},
                         min: 0,
                     }
                 }
             });
}

function draw_price_chart( cid, sid, pricedate, price_chart_id, side ) {

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

    var series_data = [
        {label:'Price   ',color:'#56617F'},
        {label:'S&P 500 ',color:'orange'},
    ];

    var stk_series = new Array();
    var mrk_series = new Array();

    var stk_factor = 1;
    var mrk_factor = 1;

    // find price date and set values
    for (var i=0; i < json_data.length; i++) {

        if (json_data[i].mrk_price == null || json_data[i].mrk_price == 0) {
            if (i>0)
                json_data[i].mrk_price = json_data[i-1].mrk_price;
        }

        if (json_data[i].datadate == pricedate) {

            stk_factor = json_data[i].ajex;
            mrk_factor = json_data[i].price/json_data[i].mrk_price;
        }
    }

    for(var i=0; i < json_data.length; i++) {

        stk_series[i] = new Array(2);
        mrk_series[i] = new Array(2);

        stk_series[i][0] = json_data[i].datadate;
        stk_series[i][1] = (json_data[i].price / json_data[i].ajex) * stk_factor;
        mrk_series[i][0] = json_data[i].datadate;
        mrk_series[i][1] = json_data[i].mrk_price * mrk_factor;

    }

    date = new Date(pricedate);
    date.setYear(1900+date.getYear()+1);
    var max_date = date.toISOString().substring(0,10);

    $.jqplot(price_chart_id,[stk_series,mrk_series],
             {
                 fontFamily: 'Helvetica',
                 title: {
                     text: 'Price / Performance',
                     fontFamily: 'Helvetica',
                     textAlign: 'left',
                 },
                 seriesDefaults:{
                     shadow: false,
                     lineWidth: 1.0,
                     showMarker: false
                 },
                 series: series_data,
                 grid: {
                     background: '#F2F2F2',
                     shadow: false,
                 },
                 legend: {
                     show: true,
                     location: 'nw',
                     xoffset: 0,
                     yoffset: 0
                 },
                 axes:{
                     xaxis:{
                         renderer:$.jqplot.DateAxisRenderer,
                         tickOptions:{formatString:'%b %y'},
                         max: max_date,
                     },
                     yaxis: {
                         pad: 1.05,
                         tickOptions: {formatString: '$%d'},
                         min: 0,
                     }
                 }
             });
}

function start_spinner(id) {

    // Create the Spinner with options
    var spinner = new Spinner({
        lines: 12, // The number of lines to draw
        length: 7, // The length of each line
        width: 4, // The line thickness
        radius: 10, // The radius of the inner circle
        color: '#000', // #rbg or #rrggbb
        speed: 1, // Rounds per second
        trail: 100, // Afterglow percentage
        shadow: false // Whether to render a shadow
    });

    spinner.spin(document.getElementById(id));

}

var EXCHANGE_NAMES = { '14' : 'NASDAQ'   ,
                       '13' : 'OTC'      ,
                       '12' : 'NYSE MKT' ,
                       '11' : 'NYSE'     }

function exchange_code_to_name(code,ticker) {

    if (code in EXCHANGE_NAMES)
        return EXCHANGE_NAMES[code];
    else if (code <= 4)
        return 'INACT'
    else if (ticker.length <= 3)
        return 'NYSE'
    else
        return 'N/A'

}

function get_row_from_year(year) {

    year = parseInt(year);

    if (year < 1980)
        return 3;
    else if (year < 1990)
        return 2;
    else if (year < 2000)
        return 1;
    else
        return 0;

}

function createLine(x1,y1, x2,y2) {
    //alert("creating line "+x1+" "+y1+" "+x2+" "+y2);

    var length = Math.sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2));
    var angle  = Math.atan2(y2 - y1, x2 - x1) * 180 / Math.PI;
    var transform = 'rotate('+angle+'deg)';

    var line = $('<div>')
        .appendTo('body')
        .addClass('line')
        .css({
            'position': 'absolute',
            'transform': transform
        })
        .width(length)
        .offset({left: x1, top: y1});

    return line;
}
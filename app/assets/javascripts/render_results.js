var pos_small_icon = "assets/green-outperformance-small.png";
var neg_small_icon = "assets/red-outperformance-small.png";
var pos_big_icon   = "assets/green-outperformance-small.png";
var neg_big_icon   = "assets/red-outperformance-small.png";


function update_positions() {
    console.log(navigator.userAgent);
    agent = navigator.userAgent;

    // if there is "WebKit" it is either Safari or Chrome
    if (agent.indexOf("WebKit") != -1) {

        // If it says Chrome, it is chrome.
        if (agent.indexOf("Chrome") != -1) {
            // console.log("Browser is Chrome");
            $(".target-info").css("top", "-7px");
        }   
        else {
            // it must be Safari
            // console.log("Browser is Safari");
            $(".date-label").css("top", "-5px");
            $(".target-name").css("top", "0px");
            $(".target-info").css("top", "9px");
        }
    }
    else if (agent.indexOf("Firefox") != -1) {
        // console.log("Browser is Firefox");
    }
    else {
        // console.log("Browser is IE or unknown");
    }    
}

$( window ).load(function() {
    update_positions();
});

function render_results(search_id) {

    $('.result-container').each(function( index ) {

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
                        //start_spinner(this_obj.attr('id'));
                        start_spinner(this_obj);
                        //$(search_status).css("display","inline-block");
                        //$(search_status).css("margin","30px 0px 0px 0px");
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

            $("#summary-avg-under")
                .html(EGUI.fmtAsNumber(data.mean_under,{fmtstr:"%.2f%%"}));

            $("#summary-avg-over")
                .html(EGUI.fmtAsNumber(data.mean_over,{fmtstr:"%.2f%%"}));
	    
	    if ((data.mean_under != null) && (data.mean_under < 0))
		$("#summary-avg-under").css('color','red');

            if ((data.count != null) && (data.wins != null)) {
            
		$('#summary-count-all').html(data.wins + ' of ' + data.count);
		$('#summary-count').html(data.wins + ' of ' + data.count);
            }

            if (!data.complete) setTimeout(poll_for_summary,3000);

        });

    })();

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

    var panel_name = panel.find('.panel-name');
    panel_name.html(data[i].name);
    panel.tooltip({
      placement: 'top',
      title: 'Click to see detailed factor comparison to ' + data[i].name,
      container: "body"
    });

    var url = 'search_detail?search_detail_id='+data[i].search_detail_id;
    panel.click( function() { window.location=url } );

    /*****
    panel_name.click(function() {

        $('#comparable-modal').modal('show');
        var idx = 10 * row + col;

        $('#comparable-carousel-right').carousel(idx);
    });***/

    var ticker = data[i].ticker;
    var exchg  = exchange_code_to_name(data[i].exchg,ticker);

    panel.find('.panel-ticker').html(exchg+': '+ticker);

    var dd = new Date(data[i].pricedate);

    var datearr = dd.toDateString().split(" ");
    var datestr = datearr[1] + " " + datearr[2] + ", " + datearr[3];

    panel.find('.panel-date').html(datestr);

    // calc outperformance
    var perf_stk = data[i].stk_rtn;
    var perf_mrk = data[i].mrk_rtn;
    var perf_net = perf_stk - perf_mrk;

    if (perf_stk >= 0) {
	panel.find(".perf-stk").html(sprintf("%.2f%%",perf_stk)).css('color','green');
    } else {
	panel.find(".perf-stk").html(sprintf("%.2f%%",perf_stk)).css('color','red');
    }

    if (perf_mrk >= 0) {
	panel.find(".perf-mrk").html(sprintf("%.2f%%",perf_mrk)).css('color','green');
    } else {
	panel.find(".perf-mrk").html(sprintf("%.2f%%",perf_mrk)).css('color','red');
    }

    if (perf_net >= 0) {
	panel.find(".perf-net").html(sprintf("%.2f%%",perf_net)).css('color','green');
    } else {
	panel.find(".perf-net").html(sprintf("%.2f%%",perf_net)).css('color','red');
    }

    var sim_score = data[i].sim_score;
    var score_str = (sim_score != null) ? sprintf("%.2f",sim_score) : "N/A";
    panel.find('.panel-similarity').html('Similarity Score: ' + score_str);

    // show makes the panel visible (the template from which it
    // was cloned was invisible)
    panel.show();

    // This packs  the panel into the DOM so it can be seen
    var theList = $(row_obj).find("ul");
    var listItem = document.createElement("li");
    $(theList).append(listItem);
    $(listItem).append(panel);
}

function start_spinner( obj ) {

    // Create the Spinner with options
    var spinner = new Spinner({
        lines: 12, // The number of lines to draw
        length: 6, // The length of each line
        width: 4, // The line thickness
        radius: 8, // The radius of the inner circle
        color: '#000', // #rbg or #rrggbb
        speed: 1, // Rounds per second
        trail: 100, // Afterglow percentage
        shadow: false // Whether to render a shadow
    });

    var status_div = obj.find('.search-status');

    spinner.spin( document.getElementById(obj.attr('id')) );

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
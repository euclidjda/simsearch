
var pos_small_icon = "assets/green-outperformance-small.png";
var neg_small_icon = "assets/red-outperformance-small.png";
var pos_big_icon   = "assets/green-outperformance-big.png";
var neg_big_icon   = "assets/red-outperformance-big.png";

function render_results(search_id_list) {

    $.getJSON('get_search_summary?search_id_list='+search_id_list,function(data) {

        var perf = data.summary

        if (perf >= 0) {
            $("#summary-image").attr("src",pos_big_icon);
            $("#summary-num").html(sprintf("%.2f%%",perf));
        } else {
            $("#summary-image").attr("src",neg_big_icon);
            $("#summary-num").html(sprintf("%.2f%%",perf));
        }
	
    });

    $('.epoch').each(function( index ) {
        var postData = new Object();
        var search_id = $(this).attr('search_id');

        start_spinner(search_id);

        postData['search_id'] = search_id;

        $.getJSON('get_search_results', postData, function(data) {

            $('[search_id='+search_id+']').empty();

            if (data.length == 1 && (typeof(data[0])=="string")) {
		
        	// If the json API isn't able to get a search result, it only
        	// returns 1 record that is a string with a message. In that 
        	// event, we display the message here ...

                $('[search_id='+search_id+']').append(data[0]);

            } else {

                // ... otherwise we process the results here:

                var max_panels = Math.min(3,data.length); // only show three panels

                for (var i=0; i < max_panels; i++) {

		    populate_panels(data,search_id,i);

                }
            }

	});

    });

    $('#comparable-carousel-right').carousel('pause');	

}

function populate_panels(data,search_id,i) {
    
    var year = data[i].pricedate.substring(0,4);
    var epoch = get_epoch(year);

    // clone the invisible template and drop data into clone
    panel = $('#comparable-panel-template').clone();
    panel.attr('id','panel'+i);

    // TODO: JDA Not sure the best way to truncate the string here
    // we really just want it to not flow over the panel
    panel.find('#panel-name').html(data[i].name.substring(0,23));
    
    var ticker = data[i].ticker;
    var exchg  = exchange_code_to_name(data[i].exchg,ticker);

    panel.find('#panel-ticker').html(exchg+': '+ticker);

    var dd = new Date(data[i].pricedate);

    var datearr = dd.toDateString().split(" ");
    var datestr = datearr[1] + " " + datearr[2] + ", " + datearr[3]; 

    panel.find('#panel-date').html(datestr);
    
    // calc outperformance
    var perf = data[i].stk_rtn - data[i].mrk_rtn;
    
    if (perf >= 0) {
        panel.find("#perf-image").attr("src",pos_small_icon);
        panel.find("#perf-num").html(sprintf("%.2f%%",perf));
    } else {
        panel.find("#perf-image").attr("src",neg_small_icon);
        panel.find("#perf-num").html(sprintf("%.2f%%",perf));
    }
    
    var sim_score = sprintf("%.2f", 
			    (100 * Math.exp(-(data[i].distance))));
    
    panel.find('#panel-similarity')
	.html('Similarity Score: '+ sim_score);
    
    // show makes the panel visible (the template from which it 
    // was cloned was invisible)
    panel.show();

    // TODO: For some reason this is not working properly
    var item_idx = 3*epoch + i;
    panel.click(function() {
	$('#comparable-carousel-right').carousel(item_idx);
        $('#comparable-modal').modal('show');
    });

    // This packs  the panel into the DOM so it can be seenn
    $('[search_id='+search_id+']').append(panel);

    // Add to detailed compare
    var detail_item = $('#carousel-item-right-template').clone();
    detail_item.attr('id','carousel-item-right-' + epoch + '-' + i);
    detail_item.removeAttr('style');

    detail_item.find('.company-name').html(data[i].name);

    detail_item.find('.ticker').html('<b>'+exchg+'</b>: '+ticker);

    detail_item.find('.year').html(datearr[3]);

    detail_item.find('.date').html(datestr);

    detail_item.find('.mrkcap-txt').html(
	EGUI.fmtAsNumber(data[i].mrkcap,{fmtstr:"%.0f"})+'M');

    detail_item.find('.price-txt').html(
	EGUI.fmtAsMoney(data[i].price,{fmtstr:"%.2f"}));
    
    detail_item.find('.dividend-txt')
	.html(sprintf("%s (%s)",
		      EGUI.fmtAsMoney(data[i].dvpsxm_ttm,
				      {fmtstr:"%.2f"}),
		      EGUI.fmtAsNumber(data[i].yield*100,
				       {fmtstr:"%.1f%%"})));		    
    detail_item.find('.eps-txt').html(
	EGUI.fmtAsMoney(data[i].epspxq_ttm,{fmtstr:"%.2f"}));

    detail_item.find('.pe-txt').html(sprintf("%.2f",data[i].pe));
    detail_item.find('.pb-txt').html(sprintf("%.2f",data[i].pb));

    detail_item.find('.factor-ey')
	.html('EYd: '+ sprintf("%.2f%%",data[i].ey*100));

    detail_item.find('.factor-roc')
	.html('ROC: '+
	      EGUI.fmtAsNumber(data[i].roc*100,{fmtstr:"%.2f%%"}));


    detail_item.find('.factor-grwth')
	.html('GRW: '+
	      EGUI.fmtAsNumber(data[i].grwth*100,{fmtstr:"%.2f%%"}));

    detail_item.find('.factor-epscon')
	.html('CON: '+
	      EGUI.fmtAsNumber(data[i].epscon,{fmtstr:"%.2f"}));


    detail_item.find('.factor-ae')
	.html('LIQ: ' +
	      EGUI.fmtAsNumber(data[i].ae*100,{fmtstr:"%.2f%%"}));

    detail_item.find('.factor-momentum')
	.html('MOM: '+
	      EGUI.fmtAsNumber(data[i].momentum*100,
			       {fmtstr:"%.2f%%"}));

    if (!i && !epoch) detail_item.addClass('active');

    $('#carousel-inner-right').append(detail_item);


}

function start_spinner(search_id) {

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

    spinner.spin(document.getElementById('epoch'+search_id));

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

function get_epoch(year) {

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

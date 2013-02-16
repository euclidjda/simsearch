

$(document).ready(function() {

    var search_id_list = $('#all-search-ids').attr('search_ids');

    // Only handle the output if we are on the results page. This script
    // loads for all pages, so we need to make sure.
    if (search_id_list) {

        // What we should do here is block until we know the search result is done.
        
        render_results(search_id_list);

	$('#comparable-carousel-right').carousel('pause');	

    }

});

function render_results(search_id_list) {

    var pos_small_icon = "assets/green-outperformance-small.png";
    var neg_small_icon = "assets/red-outperformance-small.png";
    var pos_big_icon   = "assets/green-outperformance-big.png";
    var neg_big_icon   = "assets/red-outperformance-big.png";

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
                    
		    var year = data[i].pricedate.substring(0,4);
		    var epoch = get_epoch(year);

                    // clone the invisible template and drop data into clone
                    panel = $('#comparable-panel-template').clone();
		    panel.attr('id','panel'+i);

                    panel.click(function() {
                        $('#comparable-modal').modal('show');
                    })

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

                    // This packs  the panel into the DOM so it can be seenn
                    $('[search_id='+search_id+']').append(panel);

		    // Add to detailed compare
		    var detail_item = $('#carousel-item-right-template').clone();
		    detail_item.attr('id','carousel-item-right-'+i);
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
						      {fmtstr:"%.1f"}),
				      EGUI.fmtAsNumber(data[i].yield*100,
						       {fmtstr:"%.1f%%"})));		    
		    detail_item.find('.eps-txt').html(
			EGUI.fmtAsMoney(data[i].epspxq_ttm,{fmtstr:"%.2f"}));

		    detail_item.find('.pe-txt').html(sprintf("%.2f",data[i].pe));
		    detail_item.find('.pb-txt').html(sprintf("%.2f",data[i].pb));
		    
		    if (!i && !epoch) 
			detail_item.addClass('active');

		    $('#carousel-inner-right').append(detail_item);

                }
            }
	});
    });
    
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

/*
  Event Handlers for button.click, document.ready, etc.
*/

function logout_action_handler() {
    NAU.log("Logout");

    $.ajax({
        url: '/logout',
        type: 'GET',
        success: function() {
            NAU.log("Session destroyed. Navigating back to the homepage.");
            NAU.navigate("/");
        }
    });
}

/*
***
*/
$(function() {
    
    // Bind click event handler for login/logout
    $("#banner-logout-btn").click(function(){
        logout_action_handler();
    });

    // Activate/Deactivate on click for nav-bar items
    $(".nav-tabs li ").click(function() {
        $(".active").removeClass("active");
        $(this).addClass("active");
    });

    function split( val ) {
        return val.split( " " );
    }

    function extractLast( term ) {
        return split( term ).pop();
    }

    function validateModalField(theField) {
        var theValue = theField.val();
        var errCount = 0;

        if (theValue.length == 0) {
            errCount++;
            $(theField).css("border-color", "red");
        }
        else {
            $(theField).css("border-color", "#CCC");
        }

        return errCount;
    }

    function validateModalDialog(dialogName) {
        var email, username, password;
        var errCount = 0;

        errCount += validateModalField($('#' + dialogName + '_email_entry'));
        errCount += validateModalField($('#' + dialogName +'_username_entry'));
        errCount += validateModalField($('#' + dialogName +'_password_entry'));

        // if there is no content, do not submit the form, save time.
        if (errCount > 0) {
            $('#' + dialogName +'-modal-message').text("  Please complete highlighted fields.");
            $('#' + dialogName +'-modal-message').css("color", "red");
            return false;
        }        
    }

    //
    // Register/login modal submit handler.
    // Allows validating content before making a database call and refreshing screen.
    //
    $( "#register-modal-form" ).submit(function() {
        return validateModalDialog("register");
    });

    $( "#login-modal-form" ).submit(function() {
        return validateModalDialog("login");
    });

    //
    // Search form submit handler.
    // Alters the content from the search field before we submit to the form.
    //
    $( "#search-bar-form" ).submit(function() {

        var submitContent = $('#ticker').val();

        // if there is no content, do not submit the form, save time.
        if (submitContent.length == 0) {
            return false;
        }

        // Trim spaces off the edges.
        submitContent = $.trim(submitContent);
        $('#ticker').val(submitContent);
    });

    // Search field autocomplete handler/renderer
    $( "#ticker" )
        .bind( "keydown", function( event ) {
            if ( event.keyCode === $.ui.keyCode.TAB &&
                    $( this ).data( "autocomplete" ).menu.active ) {
                event.preventDefault();
            }

            // add logic to close the dropdown whenever a comma is typed, whether 
            // the term before it is typed properly or not is irrelevant at this point.
            if (event.keyCode === $.ui.keyCode.SPACE) {
                $( this ).data( "autocomplete" ).close();
            }
        })
        .autocomplete({
            minLength: 2,
             search: function() {
                // custom minLength
                var term = extractLast( this.value );
                console.log("Term is: ->" + term + "<-, length=" + term.length);
                if ( term.length < 2 ) {
                    // If the term has less then 2 characters close the menu. 
                    // This can happen if we we are editing characters in a secondary term.
                    $( this ).data( "autocomplete" ).close();
                    return false;
                }
            },
            source: function( request, response ) {

                //  For both tickers and filters we have a single source, simplifies things.
                //  The search controller decides which query to run, this script block decides what to render.
                $.ajax({
                    type: 'GET',
                    url: "/autocomplete_security_ticker.json",
                    dataType: "json",
                    data: { term: extractLast(request.term) },
                    success: function( data ) {
                        response( data );
                    }
                });
            },
            select: function( event, ui ) {
                console.log( ui.item ?
                    "Selected: " + ui.item.sid + ":" + ui.item.cid + " - " + ui.item.value + " - "+ ui.item.longname :
                    "Nothing selected, input was " + this.value );
                
                var terms = split( this.value );
                // remove the current input
                terms.pop();

                // add the selected item
                terms.push( ui.item.value );
                
                // add placeholder to get the comma-and-space at the end
                terms.push( "" );
                this.value = terms.join( " " );
                return false;
            },
            change: function( event, ui ) {
                console.log("Selection changed");
            },
            focus: function() {
                // prevent value inserted on focus
                return false;
            },
        })
        .data( "autocomplete" )._renderItem = function( ul, item ) {

            var v = item.value + " - " + item.longname;

            return $( "<li></li>" )
                .data( "item.autocomplete", item )
                .append( "<a>" + v + "</a>" )
                .appendTo( ul );
        };
});
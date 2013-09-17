
$(document).ready(function() {

    init_kissmetrics();

    init_frontdoor();

    handle_teaser();

    handle_search();

    handle_search_detail();

});

function init_kissmetrics() {

    var _kmq = _kmq || [];
    var _kmk = _kmk || '323c91cff253a60d0decffd3ee862ac251bae26d';
    function _kms(u){
	setTimeout(function(){
	    var d = document, f = d.getElementsByTagName('script')[0],
	    s = d.createElement('script');
	    s.type = 'text/javascript'; s.async = true; s.src = u;
	    f.parentNode.insertBefore(s, f);
	}, 1);
    }
    _kms('//i.kissmetrics.com/i.js');
    _kms('//doug1izaerwt3.cloudfront.net/' + _kmk + '.1.js');

}

function init_frontdoor() {

    $('#custom-search-config').click( function() {

	update_weight_labels();

        var offset = $('#ticker').offset();
        var width  = $('#ticker').outerWidth();
        var height = $('#ticker').outerHeight();

        var left = offset.left + 'px';
        var top  = (offset.top+height) + 'px';
        
        $('#custom-search-modal').css('left',left);
        $('#custom-search-modal').css('top',top);
        $('#custom-search-modal').css('width',width);

        $('#custom-search-modal').modal('show');

    });

    for (var i=1; i<= 6; i++) { 

	var slider_value = $('#weight-hidden'+i).attr('value');

        $('#weight-slider'+i).slider(
            { min:   0,
              max:   10,
	      step:  1,
	      value: slider_value,
	      slide: slider_change
            });
    }

    $('#restore-defaults').click( function() {

	var weight = $('.weight-hidden').attr('default');

	$('.weight-slider').slider('value',weight);
	$('.weight-hidden').attr('value',weight);

	update_weight_labels();

	$('#factor1').val($('#factor1').attr('default'))
	$('#factor2').val($('#factor2').attr('default'))
	$('#factor3').val($('#factor3').attr('default'))
	$('#factor4').val($('#factor4').attr('default'))
	$('#factor5').val($('#factor5').attr('default'))
	$('#factor6').val($('#factor6').attr('default'))

	$('.industry-select').val($('.industry-select').attr('default'));

    });

}

function slider_change(event,ui) {

    var index = $(this).attr('index');
    var value = ui.value;
    $('#weight-hidden'+index).attr('value',value);

    update_weight_labels();
}

function update_weight_labels() {
    var e=0;
    
    for(var t=1;t<=6;t++)
	e+=parseInt($("#weight-hidden"+t).attr("value"));

    for(var t=1;t<=6;t++) {
	var n=parseInt($("#weight-hidden"+t).attr("value"));
	r= e > 0 ? n/e : 0;
	$("#weight-label"+t).html(sprintf("%.1f%%",100*r))
    }

}

function handle_teaser() {

    var teaser = $('#teaser-carousel');

    if (teaser) {
        $('#teaser-carousel').carousel( { interval: 15000 } );
    }

}

function handle_search() {

    var search_id = $('#search-info').attr('search-id');

    // Only handle the output if we are on the results page. This script
    // loads for all pages, so we need to make sure.
    if (search_id) {
        // This function is implemented render_results.
        render_results(search_id);
    }

}

function handle_search_detail() {

    var cid = $('.results-detail').attr('cid');
    var sid = $('.results-detail').attr('sid');
    var pricedate = $('.results-detail').attr('pricedate');

    if (cid && sid && pricedate) {
	
	draw_price_chart( cid, sid, pricedate, 'price-chart' );
	draw_growth_chart( cid, sid, pricedate, 'growth-chart' );

    }

}

/*
  Event Handlers for button.click, document.ready, etc.
*/

function signout_action_handler() {
    NAU.log("Signout");

    $.ajax({
        url: '/signout',
        type: 'POST',
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

    // Bind click event handler for signout
    $("#banner-signout-btn").click(function(){
        signout_action_handler();
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

    function validateIdentityField(theField) {
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

    function validateIdentityForm(dialogName) {
        var email, username, password;
        var errCount = 0;

        if (dialogName == "register") {
            errCount += validateIdentityField($('#' + dialogName +'_username_entry'));
        }

        errCount += validateIdentityField($('#' + dialogName + '_email_entry'));
        errCount += validateIdentityField($('#' + dialogName +'_password_entry'));

        // if there is no content, do not submit the form, save time.
        if (errCount > 0) {
            $('#' + dialogName +'-message').text("  Please complete highlighted fields.");
            $('#' + dialogName +'-message').css("color", "red");
            return false;
        }        
    }

    //
    // Register/signin submit handler.
    // Allows validating content before making a database call and refreshing screen.
    //
    $( "#register-form" ).submit(function() {
        return validateIdentityForm("register");
    });

    $( "#signin-form" ).submit(function() {
        return validateIdentityForm("signin");
    });

    // Search bar and autocomplete is only used on home page or search page.
    // Attempting to run this code on other pages will cause script errors since some elements
    // that are looked for by jquery statements won't be found. Only call this on home and search pages.
    var isHomeorSearch = (window.location.href.indexOf("/search") > 0);
    isHomeorSearch = isHomeorSearch || (window.location.href.indexOf("/home") > 0);
    if (isHomeorSearch) {
        Prepare_and_Handle_Search_Form();
    }    

    function Prepare_and_Handle_Search_Form() {
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
        $( ".ticker-entry" )
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
                minLength: 1,
                 search: function() {
                    // custom minLength
                    var term = extractLast( this.value );
                    // console.log("Term is: ->" + term + "<-, length=" + term.length);
                    if ( term.length < 1 ) {
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
                    // console.log( ui.item ?
                    //     "Selected: " + ui.item.sid + ":" + ui.item.cid + " - " + ui.item.value + " - "+ ui.item.longname :
                    //     "Nothing selected, input was " + this.value );
                    
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
                    // console.log("Selection changed");
                },
                focus: function() {
                    // prevent value inserted on focus
                    return false;
                },
            })
            .data( "autocomplete" )._renderItem = function( ul, item ) {

                ul.css('z-index',99);

                var v = item.value + " - " + item.longname;

                return $( "<li></li>" )
                    .data( "item.autocomplete", item )
                    .append( "<a>" + v + "</a>" )
                    .appendTo( ul );
            };        
    }
});
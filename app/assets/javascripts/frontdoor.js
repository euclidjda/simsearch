// Analytics Queues: need to be global

var _kmq;
var _gaq;

$(document).ready(function() {

    init_analytics();

    init_frontdoor();

    handle_search();

    handle_search_detail();

});

function init_analytics() {

    // GOOGLE
    _gaq = _gaq || [];
    _gaq.push(['_setAccount', 'UA-45438212-2']);
    _gaq.push(['_trackPageview']);
    
    (function() {
	var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
	ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + 
	    '.google-analytics.com/ga.js';
	var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
    })();

    // KISS METRICS
    _kmq = _kmq || [];
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

    for (var i=1; i<= 6; i++) { 

	var slider_value = parseInt( $('#weight-hidden'+i).attr('value') );

        $('#weight-slider'+i).slider(
            { min:   0,
              max:   10,
	      step:  1,
	      value: slider_value,
	      slide: slider_change
            });

	factor_enable_disable(i,slider_value);

    }

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

    $('#restore-defaults').click( function() {

	for (var i=1; i<= 6; i++) { 

	    $('#factor'+i).val($('#factor'+i).attr('default'))

	    var value = parseInt( $('#weight-hidden'+i).attr('default') );
	    $('#weight-hidden'+i).attr('value',value);
	    $('#weight-slider'+i).slider('value',value);
	    factor_enable_disable(i,value);

	}

	update_weight_labels();

    });

}

function factor_enable_disable(index,value) {

    if (!value) {
	$('#factor'+index).attr('disabled',true);
	$('#factor'+index).css('color','#CCCCCC');
	$('#factor'+index).val($('#factor'+index).attr('default'));
    } else {
	$('#factor'+index).attr('disabled',false);
	$('#factor'+index).css('color','black');
    }

}

function slider_change(event,ui) {

    var index = $(this).attr('index');
    var value = ui.value;
    $('#weight-hidden'+index).attr('value',value);

    update_weight_labels();
    //change_customize_label();

    factor_enable_disable(index,value);

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

function change_customize_label() {
    $('#custom-search-config').css('color','red');
    $('#custom-search-config').html('<b>&iexcl; Custom Search !</b>');
}

function handle_search() {


    var search_id = $('#search-info').attr('search-id');

    // Only handle the output if we are on the results page. This script
    // loads for all pages, so we need to make sure.
    if (search_id) {
        // This function is implemented in render_results.
        $.getJSON('get_search_info?search_id='+search_id)
        .done(function(search_info) {
            //console.log('search is '+search_info['ticker']);
            _kmq.push(['record', 'Executed Search',search_info]);
	    _gaq.push(['_trackEvent',
		       'Executed Search',
		       search_info.ticker,
		       search_info.factors+'|'+search_info.weights]);
        });

        render_results(search_id);
    }

}

function handle_search_detail() {

    var cid = $('.results-detail').attr('cid');
    var sid = $('.results-detail').attr('sid');
    var pricedate = $('.results-detail').attr('pricedate');

    if (cid && sid && pricedate) {
        
        draw_detail_chart( cid, sid, pricedate);
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
        var errorMessage = "<b>Please correct the following so we can register you: </b><br>";

        // always need a password and e-mail. no matter what the form type is.
        var retVal = validateIdentityField($('#' + dialogName + '_email_entry'));
        if (retVal > 0) {
            errCount += 1;
            errorMessage += "Provide a valid and unique e-mail address. <br>";
        }

        retVal = validateIdentityField($('#' + dialogName +'_password_entry'));
        if (retVal > 0) {
            errCount += 1;
            errorMessage += "Provide a password. <br>";
        }

        if (dialogName == "register") {

            retVal = validateIdentityField($('#register_username_entry'));
            if (retVal > 0) {
                errCount += 1;
                errorMessage += "Please provide a user name. <br>";
            }

            retVal = validateIdentityField($('#register_password_entry_verify'));
            if (retVal > 0) {
                errCount += 1;
                errorMessage += "Please re-enter password in the verification field. <br>";
            }

            var password = $("#register_password_entry").val();
            var password_verify = $("#register_password_entry_verify").val();

            if (password != password_verify) {
              $("#register_password_entry_verify").val("");
              $("#register_password_entry_verify").attr("placeholder", "Passwords need to match");
              $("#register_password_entry_verify").css("border", "1px solid rgb(255, 0, 0)");

              errCount += 1;  
              errorMessage += "Passwords do not match. <br>";;
            }     

            // Make sure there is an entry in the captcha
            retVal = validateIdentityField($("#recaptcha_response_field"));
            if (retVal > 0) {
                errCount += 1;
                errorMessage += "Captcha text is not entered. <br>"
            }
        }

        // if there is no content, do not submit the form, save time.
        if (errCount > 0) {
            $('#' + dialogName +'-message').text("  Please complete highlighted fields.");
            $('#' + dialogName +'-message').css("color", "red");

            // show an error dialog
            $("#errormodal-message").html(errorMessage);
            $("#errormodal").modal();

            return false;
        }        
        else {
            return true;
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

    Prepare_and_Handle_Search_Form();

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
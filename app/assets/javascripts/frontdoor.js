
$(document).ready(function() {

    var teaser = $('#teaser-carousel');

    if (teaser) {
	$('#teaser-carousel').carousel( { interval: 15000 } );
    }

    var search_id_list = $('#all-search-ids').attr('search_ids');

    // Only handle the output if we are on the results page. This script
    // loads for all pages, so we need to make sure.
    if (search_id_list) {
    	// This function is implemented render_results.
    	render_results(search_id_list);
    }

});

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
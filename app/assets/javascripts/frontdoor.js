$(function() {

    $("#banner-logout-btn").click(function(){
        logout_action_handler();
    });
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

    //
    // In case we want to handle the content from the search field before we submit to the form.
    //
    $( "#search-bar-form" ).submit(function() {

       var submitContent = $('#search_entry').val();

       // if there is no content, do not submit the form, save time.
       if (submitContent.length == 0) {
        return false;
       }

       // Trim spaces off the edges.
       submitContent = $.trim(submitContent);
       $('#search_entry').val(submitContent);
    });

    $( "#search_entry" )
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

            // console.log("rendering items");

            var v = item.value + " - " + item.longname;

            return $( "<li></li>" )
                .data( "item.autocomplete", item )
                .append( "<a>" + v + "</a>" )
                .appendTo( ul );
        };
});

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
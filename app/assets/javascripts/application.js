// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery-1.8.2.min
//= require jquery-ui-1.9.1.custom.min 
//= require bootstrap
//= require_tree .

$(function() {
   function split( val ) {
        return val.split( /,\s*/ );
    }
    function extractLast( term ) {
        return split( term ).pop();
    }

	$( "#search_entry" )
        .bind( "keydown", function( event ) {
            if ( event.keyCode === $.ui.keyCode.TAB &&
                    $( this ).data( "autocomplete" ).menu.active ) {
                event.preventDefault();
            }

            // add logic to close the dropdown whenever a comma is typed, whether 
            // the term before it is typed properly or not is irrelevant at this point.
            if (event.keyCode === $.ui.keyCode.COMMA) {
				$( this ).data( "autocomplete" ).close();
            }
        })
		.autocomplete({
		    minLength: 2,
             search: function() {
                // custom minLength
                var term = extractLast( this.value );
                if ( term.length < 2 ) {
                    return false;
                }
            },
            source: function( request, response ) {

            	//	For both tickers and filters we have a single source, simplifies things.
            	//  The search controller decides which query to run, this script block decides what to render.
		    	$.ajax({
		    		type: 'GET',
                    url: "/search/autocomplete_security_ticker.json",
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
	            this.value = terms.join( ", " );
	            return false;
		    },
		    change: function( event, ui ) {
		    	console.log("change happened");
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
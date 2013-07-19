
  
// Global variables for search actions page, that are used for current context 
// throughout the UI.
var global_search_id;
var global_search_ticker;

String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
}

function hideSearchInfo() {
  // in case this is the first time we are clicking anything, hide 
  // search-info block that would be showing information.
  $('.searches-info').hide();
}

function hideSearchDetail() {
  $('.searches-detail').hide();
}

function showSearchDetail(_action) {
  $(".searches-detail").show();
  $("." + _action + "-detail").show();
}

function hideAlerts() {
  $('.alert').hide();
}

function ShowOrHideShareAction(_action) {
  
  // for "shared" view, we hide the sharing action.

  if (_action == "shared") {
    $("#sharing-action").hide();    
  }
  else {
    $("#sharing-action").show();
  }
}

function handleSearchAction(e, _action, _search_id) {
  // alert( _action + " : " + _search_id);

  e.preventDefault();
  e.stopPropagation();

  hideAlerts();

  switch (_action) {
    case "favorite":
      break;
    
    case "refresh":
      alert("not yet.");
      break;

    case "share":
      hideSearchInfo();
      showSearchDetail(_action);

      break;
  }
}

function updateGlobals(_search_id, _search_ticker) {
  global_search_id = _search_id;
  global_search_ticker = _search_ticker;
  
  $("#ticker-name").html(global_search_ticker.toUpperCase());
  $("#hidden_search_id").val(global_search_id);

}

function handleListItemClick(e) {
  hideSearchInfo();
  showSearchDetail(getHash());
  hideAlerts();

  // read and cache the search id and ticker from the current selection.
  var target = e.currentTarget;

  updateGlobals($(target).attr("search-id"), $(target).attr("search-ticker"));
  // console.log($(target).attr("search-id") + " " + $(target).attr("search-ticker"));

  renderSearchDetails($(target).attr("search-id"), $(target).attr("search-ticker"));
}

function getSummaryText (_secdata, _sumdata, _search_id) {
    var performanceSign, performanceNumber;
    var content;

    var styleTemplate = "<span style='color:%s'>%s</span>";
    var sign;
    if (_sumdata.mean > 0) {
      sign = "green";
      overunder = "overperformed";
    }
    else {
      sign = "red";
      overunder = "underperformed"
    }

    performanceSign = sprintf(styleTemplate, sign, overunder); 
    performanceNumber = sprintf(styleTemplate, sign, "%.2f%%");

    sign = (_sumdata.min > 0) ? "green" : "red";
    var minComparable = sprintf("<span style='color:%s'>%s</span>", sign, "%.2f%%");

    sign = (_sumdata.max > 0) ? "green" : "red";
    var maxComparable = sprintf("<span style='color:%s'>%s</span>", sign, "%.2f%%");

    var template = 
    "<div id='result-summary-companyname'>%s</div>" + 
    "<div id='result-summary-companydetails'><b>Market Cap:</b> %.2fM <b>P/E:</b> %.2f <b>Price:</b> $%.2f </div>" + 
    "<div id='result-summary-searchsummary'>Historical Comparables %s S&P 500 by an average of " + performanceNumber + 
    ". It outperformed <b>%d out of %d</b> comparables, where worst performing comparable returned " + minComparable + " and best performing returned " + maxComparable + ".</div>" + 
    "<br><div><a href = '/search?search_id=%s'>Click to see full search results.</a></div>";

    content = sprintf(template, _secdata.name, _secdata.mrkcap, _secdata.pe, _secdata.price, 
      performanceSign, _sumdata.mean,
      _sumdata.wins, _sumdata.count, _sumdata.min, _sumdata.max, _search_id);  

    return content;
}

function renderSearchDetails(_search_id, _search_ticker) {
    var template, content, securityData, summaryData;

    // get search results
    var security_snapshot = $.getJSON('get_security_snapshot?search_id='+_search_id)
    .done(function(secdata) {

          securityData = secdata;

          $.getJSON('get_search_summary?search_id='+_search_id)

          .done(function(sumdata) {
            summaryData = sumdata;

            content = getSummaryText(securityData, summaryData, _search_id);

            $("#hidden_summary_text").val(content);

            $("#result-summary-content").html(content);               
          })
          .fail(function(sumdata){
            // console.log("failed - searchsummary");
          })
          .always(function(sumdata){
            // console.log("always - searchsummary");
          });     
    })
    .fail(function(secdata) { 
        // console.log("failed - securitysnapshot")
    })
    .always(function(secdata) { 
        // console.log("always - securitysnapshot")
    });
}

  
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

function handleSearchAction(e, _action, _search_id) {
  // alert( _action + " : " + _search_id);

  e.preventDefault();
  e.stopPropagation();

  hideAlerts();

  switch (_action) {
    case "favorite":
      alert("will add to favorites");
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
  renderSearchDetails(_search_id, _search_ticker);
}

function handleListItemClick(e) {
  hideSearchInfo();
  showSearchDetail(getHash());
  hideAlerts();

  // read and cache the search id and ticker from the current selection.
  var target = e.currentTarget;

  updateGlobals($(target).attr("search-id"), $(target).attr("search-ticker"));
  
  renderSearchDetails(global_search_id, global_search_ticker);
}

function renderSearchDetails(_search_id, _search_ticker) {
    $("#result-summary-content").html("Search ID: " + _search_id + "<br>" + "Ticker: " + _search_ticker);
}
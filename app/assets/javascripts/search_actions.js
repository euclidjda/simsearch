

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

function handleSearchAction(e, _action, _search_id) {
  // alert( _action + " : " + _search_id);

  e.preventDefault();
  e.stopPropagation();

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

      // ShowShare();

      break;
  }
}


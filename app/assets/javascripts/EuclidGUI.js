
/**************************************************************************

  Euclid Global Factory Object

  Created in June 2009 By John Alberg

  NOTE: THIS IS UNFINISHED. IT SHOULD ULTIMATELY SUPPORT THE ENTIRE DOM

  This library is useful extention of jQuery for creating DOM objects on
  the fly. The typical use case is your JS app gets data from a server
  and you need to dynamically build up a presentation of the data.

  Each method returns a jQuery object that you can do all the fun jQuery
  stuff to like .appendTo, .css, .addClass, etc.
  But they also have other methods such .addChild which allows you to
  easily add sub-elements (e.g., add a table cell to a table). The addChild
  method also returns a jQuery object (the thing that was added) that can 
  be styled or manipulated in a jQuery sort of way.

  Additionally, there are a set of useful number formatting methods. These
  methods rely on a external implementation of sprintf.

  Example: // Draw a simple table that says "Hello World"

  var tbl = EGUI.createTable( { border : 1 } ).css('color','green');

  tbl.addClass('my_table'); // This does some more styling

  tbl.addChild( 0, 0, 'Hello' , { align , 'left' } ).addClass('my_cell_a');
  tbl.addChild( 0, 1, 'World' , { align , 'right'} ).addClass('my_cell_b');

  tbl.appendTo('#my_content');

***************************************************************************/

var EGUI = new EuclidGUIFactory( );

function EuclidGUIFactory() {

  this.createTable     = Euclid_Table_createTable;
  this.createMenu      = Euclid_Menu_createMenu;
  this.createButton    = Euclid_Button_createButton;
  this.createButtonSet = Euclid_ButtonSet_createButtonSet;
  this.createTextarea  = Euclid_Textarea_createTextarea;
  this.createInput     = Euclid_Input_createInput;

  this.createObject    = Euclid_Object_createObject;
  this.setAttr         = Euclid_setAttr;
  
  this.whitespace      = Euclid_whitespace;
  this.fmtAsNumber     = Euclid_fmtAsNumber;
  this.fmtAsMoney      = Euclid_fmtAsMoney;

}

/**************************************************************************

  Euclid Table Object

***************************************************************************/

function Euclid_Table_createTable(data) {

  var tblstr = _Euclid_createTagString('table',data);
  var jqobj = $(tblstr);

  var bdystr = _Euclid_createTagString('tbody', { } );
  $(bdystr).appendTo(jqobj);

  jqobj.addChild = Euclid_Table_addChild;
  jqobj.row      = Euclid_Table_row;
  jqobj.cell     = Euclid_Table_cell;

  return jqobj;
}

function Euclid_Table_addChild(row,col,obj,attr) {

  var tbody = this.children('tbody');

  if (tbody.children().length <= row) {

    var num = row - tbody.children().length + 1;

    for (var i=0; i < num; i++) {
      $('<tr></tr>').appendTo(tbody);
    }

  }

  // Grab the row by getting n-th child
  var row_ref = tbody.children(':nth-child('+(row+1)+')');

  if (row_ref.children().length <= col) {

    var num = col - row_ref.children().length + 1;
    for (var i=0; i < num; i++) {
      $('<td></td>').appendTo(row_ref);
    }

  }

  // Grab the cell by getting the n-th child
  var cell_ref = row_ref.children(':nth-child('+(col+1)+')');
  // TODO: This can be acheived by cell_ref.attr()
  // Why does _Euclid_setAttr() exist???
  _Euclid_setAttr(cell_ref,attr);

  if (typeof(obj) == 'string') {
    cell_ref.html(obj);
  } else {
    cell_ref.append(obj);
  }

  return cell_ref;
}

function Euclid_Table_row(row) {

  var tbody   = this.children('tbody');
  var row_ref = tbody.children(':nth-child('+(row+1)+')');

  return row_ref;
}

function Euclid_Table_cell(row,col) {

  var row_ref = this.row(row);
  var cell_ref = row_ref.children(':nth-child('+(col+1)+')');

}

/**************************************************************************

  Euclid Menu Object

***************************************************************************/

function Euclid_Menu_createMenu(data) {

  var menstr = _Euclid_createTagString('select',data);
  var jqobj = $(menstr);

  jqobj.addChild = Euclid_Menu_addChild;

  return jqobj;
}

function Euclid_Menu_addChild(text,data) {

  var optstr = _Euclid_createTagString('option',data,text);
  var optobj = $(optstr);

  optobj.appendTo(this);
  
  return optobj;
}

/**************************************************************************

  Euclid Button Widget

***************************************************************************/

function Euclid_Button_createButton(name,data) {

  var tblstr = _Euclid_createTagString('button',data,name);
  var jqobj = $(tblstr);

  jqobj.button();

  return jqobj;
}

/**************************************************************************

  Euclid Button Set Widget

***************************************************************************/

function Euclid_ButtonSet_createButtonSet(data) {

  var tblstr = _Euclid_createTagString('div',data);
  var jqobj = $(tblstr);

  jqobj.addChild = Euclid_ButtonSet_addChild;
  return jqobj;
}

function Euclid_ButtonSet_addChild(label,data) {

  data.type = 'radio';
  data.name = this.attr('id');

  var optstr = _Euclid_createOptionString(data);
  var tagstr = "<input "+optstr+"\>";

  var butobj = $(tagstr);

  var labstr = _Euclid_createTagString('label', { 'for' : data.id }, label );
  var labobj = $(labstr);

  butobj.appendTo(this);
  labobj.appendTo(this);

  this.buttonset();

  return butobj;
}

/**************************************************************************

  Euclid Input Widget

***************************************************************************/

function Euclid_Input_createInput(data) {

  var tblstr = _Euclid_createTagString('input',data);
  var jqobj = $(tblstr);

  return jqobj;
}

/**************************************************************************

  Euclid Text Area

***************************************************************************/

function Euclid_Textarea_createTextarea(data) {

  var tblstr = _Euclid_createTagString('textarea',data);
  var jqobj = $(tblstr);

  return jqobj;
}


/**************************************************************************

  Generic Create Object

***************************************************************************/

function Euclid_Object_createObject(tag,data,html) {

  var objstr = _Euclid_createTagString(tag,data,html);
  var jqobj  = $(objstr);

  return jqobj;
}

function Euclid_setAttr(element,attr) {
  _Euclid_setAttr(element,attr);
}

/************************************************************************

 Formatting Functions

 EGUI.fmtAsNumber(val,{decimals:2,commas:'yes',zerostr:'-',nullstr:'N/A'});
 EGUI.fmtAsMoney(val,{decimals:2,commas:'yes',currency:'$',zerostr:'-',nullstr:'N/A'});

*************************************************************************/

function Euclid_whitespace(size) {

  var st = "";
  for (var i=0; i < size; i++) {
    st += "&nbsp;";
  }
  return st;
}

function Euclid_fmtAsNumber (val,options) {

    if (options == null)
	options = new Object();
    
    if (options.fmtstr == null)
	options.fmtstr = "%.2f";
    
    if (options.commas == null)
	options.commas = 'yes';
    
    if (options.zerostr == null)
	options.zerostr = null;
    
    if (options.nullstr == null)
	options.nullstr = "N/A";
    
    if (val == null || isNaN(val))
	return options.nullstr;
    
    val = parseFloat(val);
    
    var result = "";

    if ((val == 0) && (options.zerostr!=null)) {

	result = options.zerostr;
	
    } else {
	
	result = sprintf(options.fmtstr,val);
	
	if ( options.commas == 'yes')
	    result = add_commas( result );
	
    }
    
    return result;
    
    // private helper function
    function add_commas(nStr)
    {
	nStr += '';
	x = nStr.split('.');
	x1 = x[0];
	x2 = x.length > 1 ? '.' + x[1] : '';
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(x1)) {
	    x1 = x1.replace(rgx, '$1' + ',' + '$2');
	}
	return x1 + x2;
    }
    
}

function Euclid_fmtAsMoney (val,options) {

  var str = Euclid_fmtAsNumber(val,options);
  var result = "";

  if (options == null)
    options = new Object();

  if (options.currency == null)
    options.currency = '$';

  var fc = str.substring(0,1);
  var sc = str.substring(1,2);

  if ((fc=='-' || fc=='+') && !isNaN(sc)) {

    result = fc + options.currency + str.substring(1);

  } else if (!isNaN(fc)) {

    result = options.currency + str;

  }

  return result;
}

/**************************************************************************

  Private Helper Functions

***************************************************************************/

function _Euclid_createTagString(tag,data,html) {
  
  var str = "<"+tag;

  for (var name in data) {
    str += " " + name + "='" + data[name] + "'";
  }

  if (html==null) {
    html = "";
  }

  str += ">"+html+"</"+tag+">";

  return str;
}

function _Euclid_createOptionString(data) {
  
  var str = "";

  for (var name in data) {
    str += " " + name + "='" + data[name] + "'";
  }

  return str;
}

function _Euclid_setAttr(element,attr) {

  if (element && attr) {

    element.attr( attr );

  }
  
}


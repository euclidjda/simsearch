function draw_price_chart( cid, sid, pricedate, price_chart_id ) {

    var post_data = {'cid':cid,'sid':sid,'pricedate':pricedate};
    var json_data = null;

    $.ajax({
        url:      'get_price_time_series',
        dataType: 'json',
        async:    false,
        data:     post_data,
        success:  function(data) {
            json_data = data;
        }
    });

    var series_data = [
        {label:'Price   ',color:'#56617F'},
        {label:'S&P 500 ',color:'orange'},
    ];

    var stk_series = new Array();
    var mrk_series = new Array();

    var stk_factor = 1;
    var mrk_factor = 1;

    // find price date and set values
    for (var i=0; i < json_data.length; i++) {

        if (json_data[i].mrk_price == null || json_data[i].mrk_price == 0) {
            if (i>0)
                json_data[i].mrk_price = json_data[i-1].mrk_price;
        }

        if (json_data[i].datadate == pricedate) {

            stk_factor = json_data[i].ajex;
            mrk_factor = json_data[i].price/json_data[i].mrk_price;
        }
    }

    for(var i=0; i < json_data.length; i++) {

        stk_series[i] = new Array(2);
        mrk_series[i] = new Array(2);

        stk_series[i][0] = json_data[i].datadate;
        stk_series[i][1] = (json_data[i].price / json_data[i].ajex) * stk_factor;
        mrk_series[i][0] = json_data[i].datadate;
        mrk_series[i][1] = json_data[i].mrk_price * mrk_factor;

    }

    date = new Date(pricedate);
    date.setYear(1900+date.getYear()+1);
    var max_date = date.toISOString().substring(0,10);

    $.jqplot(price_chart_id,[stk_series,mrk_series],
             {
                 fontFamily: 'Helvetica',
                 title: {
                     //text: 'Price / Performance',
                     fontFamily: 'Helvetica',
                     textAlign: 'left',
                 },
                 seriesDefaults:{
                     shadow: false,
                     lineWidth: 1.0,
                     showMarker: false
                 },
                 series: series_data,
                 grid: {
                     background: '#F2F2F2',
                     shadow: false,
                 },
                 legend: {
                     show: true,
                     location: 'sw',
                     xoffset: 0,
                     yoffset: 0
                 },
                 axes:{
                     xaxis:{
                         renderer:$.jqplot.DateAxisRenderer,
                         tickOptions:{formatString:'%b %y'},
                         max: max_date,
                     },
                     yaxis: {
                         pad: 1.05,
                         tickOptions: {formatString: '$%d'},
                         min: 0,
                     }
                 }
             });
}

function draw_growth_chart( cid, sid, pricedate, growth_chart_id ) {

    var post_data = {'cid':cid,'sid':sid,'pricedate':pricedate};
    var json_data = null;

    $.ajax({
        url:      'get_growth_time_series',
        dataType: 'json',
        async:    false,
        data:     post_data,
        success:  function(data) {
            json_data = data;
        }
    });

   // This we will get by snycronous ajax request with cid,sid,datadate
    var revenue = Array(); //[80,120,115,130];
    var gain    = Array(); //[0,11,12,14];
    var loss    = Array(); //[14,0,0,0];

    var x_axis_labels = Array(); //['2002','2003','2004','2005'];


    for (var i=0; i < json_data.length; i++) {

        var idx = json_data.length-i-1;

        revenue[idx] = json_data[i].sale;

        var profit = json_data[i].opi;

        gain[idx] = (profit >= 0) ? profit : 0;
        loss[idx] = (profit <  0) ? -profit : 0;

        x_axis_labels[idx] = json_data[i].datadate.substring(0,4);

    }

    var series_data = [
        {label:'Revenue',color:'#56617F'},
        {label:'Operating-Income',color:'#7C8FB7'},
        {label:'Operating-Loss',color:'red'}
    ];

    $.jqplot(growth_chart_id,[revenue,gain,loss],
             {
                 fontFamily: 'Helvetica',

                 title: {
                     text: 'Historical Growth',
                     fontFamily: 'Helvetica',
                     textAlign: 'left',
                 },
                 stackSeries: true,
                 seriesDefaults:{
                     renderer:$.jqplot.BarRenderer,
                     shadow: false,
                     rendererOptions: {
                         barMargin: 30,
                     }
                 },
                 series: series_data,
                 grid: {
                     background: '#F2F2F2',
                     shadow: false,
                 },
                 legend: {
                     show: true,
                     location: 'nw',
                     xoffset: 0,
                     yoffset: 0
                 },
                 axes: {
                     xaxis: {
                         renderer: $.jqplot.CategoryAxisRenderer,
                         ticks: x_axis_labels
                     },
                     yaxis: {
                         pad: 1.05,
                         tickOptions: {formatString: '$%dM'},
                         min: 0,
                     }
                 }
             });
}


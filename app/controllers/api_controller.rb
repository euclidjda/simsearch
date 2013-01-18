class ApiController < ApplicationController

  def get_prices

    _cid = params[:cid]
    _sid = params[:sid]
    _start_date = params[:start_date]
    _end_date = params[:end_date]

    if !_cid.blank? && !_sid.blank? && !_start_date.blank? && !_end_date.blank?

      _prices = ExPrice::find_by_range(_cid,_sid,_start_date,_end_date)

      render :json => _prices.to_json

    else

      render :text => 'failed'

    end

  end

  def get_performance

    _cid = params[:cid]
    _sid = params[:sid]
    _start_date = params[:start_date]
    _end_date = params[:end_date]

    if !_cid.blank? && !_sid.blank? && !_start_date.blank? && !_end_date.blank?

      _prices = ExPrice::find_by_range(_cid,_sid,_start_date,_end_date)

      _first = _prices.first
      _last  = _prices.last

      _stk_price0 = _first.price / _first.ajex #adjust for splits
      _stk_price1 = _last.price / _last.ajex # adjust for splits
      _mrk_price0 = _first.mrk_price
      _mrk_price1 = _last.mrk_price

      _stk_rtn = 100 * (_stk_price1/_stk_price0 - 1)
      _mrk_rtn = 100 * (_mrk_price1/_mrk_price0 - 1)

      _result = { 
        :cid        => _cid,
        :sid        => _sid,
        :start_date => _start_date,
        :end_date   => _end_date,
        :stk_rtn    => _stk_rtn, 
        :mrk_rtn    => _mrk_rtn 
      }

      render :json => _result.to_json

    else

      render :text => 'failed'

    end

  end

  #
  # Method that returns details data for a particular ticker for detailed view
  #
  def details_for_ticker

  end

end

class ApiController < ApplicationController

  def get_prices

    _cid = params[:cid]
    _sid = params[:sid]
    _start_date = params[:start_date]
    _end_date = params[:end_date]

    if !_cid.blank? && !_sid.blank? && !_start_date.blank? && !_end_date.blank?

      prices = ExPrice::find_by_range(_cid,_sid,_start_date,_end_date)

      render :json => prices.to_json

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

      prices = ExPrice::find_by_range(_cid,_sid,_start_date,_end_date)

      first = prices.first
      last  = prices.last

      stk_price0 = first.price / first.ajex #adjust for splits
      stk_price1 = last.price / last.ajex # adjust for splits
      mrk_price0 = first.mrk_price
      mrk_price1 = last.mrk_price

      stk_rtn = 100 * (stk_price1/stk_price0 - 1)
      mrk_rtn = 100 * (mrk_price1/mrk_price0 - 1)

      result = {
        :cid        => _cid,
        :sid        => _sid,
        :start_date => _start_date,
        :end_date   => _end_date,
        :stk_rtn    => stk_rtn, 
        :mrk_rtn    => mrk_rtn 
      }

      render :json => result.to_json

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

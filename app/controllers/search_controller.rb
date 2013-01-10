class SearchController < ApplicationController
  #
  # Method that returns, as a json, a list of tickers that are matching the term.
  #
  def autocomplete_security_ticker
    _term = params[:term]
    if _term && !_term.empty?

      if _term[0] == ':'
        term = term[1.._term.length]
        _items = Filter.
          select("distinct id as cid, id as sid, name as shortname, description as longname").
          where("LOWER(CONCAT(name, description)) like ?", '%' + _term.downcase + '%').
          limit(10).order(:shortname)
      else
        _items = Security.
          select("distinct cid, sid, ticker as shortname, name as longname").
          where("LOWER(CONCAT(ticker, name)) like ?", '%' + _term.downcase + '%').
          limit(10).order(:shortname)
      end

    else
      _items = {}
    end

    render :json => json_for_autocomplete(_items, :shortname, [:sid, :cid, :longname])
    
  end

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

  #
  # Method that returns details data for a particular ticker for detailed view
  #
  def details_for_ticker

  end

end

class SearchController < ApplicationController
  #
  # Method that returns, as a json, a list of tickers that are matching the term.
  #
  def autocomplete_security_ticker
    term = params[:term]
    if term && !term.empty?

      if term[0] == ':'
        term = term[1..term.length]
        items = Filter.
          select("distinct id as cid, id as sid, name as shortname, description as longname").
          where("LOWER(CONCAT(name, description)) like ?", '%' + term.downcase + '%').
          limit(10).order(:shortname)
      else
        items = Security.
          select("distinct cid, sid, ticker as shortname, name as longname").
          where("LOWER(CONCAT(ticker, name)) like ?", '%' + term.downcase + '%').
          limit(10).order(:shortname)
      end

    else
      items = {}
    end

    render :json => json_for_autocomplete(items, :shortname, [:sid, :cid, :longname])
    
  end

  def get_prices

    cid = params[:cid]
    sid = params[:sid]
    start_date = params[:start_date]
    end_date = params[:end_date]

    if !cid.blank? && !sid.blank? && !start_date.blank? && !end_date.blank?

      prices = ExPrice::find_by_range(cid,sid,start_date,end_date)

      render :text => prices.to_json

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

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

end

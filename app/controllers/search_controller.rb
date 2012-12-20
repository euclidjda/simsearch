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
          select("distinct cid, sid, name as shortname, description as longname").
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

  #
  # Method that returns a list of comparable investmentments for a particular ticker
  #
  def comparables_for_ticker

    cid = params[:cid]
    sid = params[:sid]
    datadate = params[:datadate]
    
    if !cid.blank? && !sid.blank? && !datadate.blank? 

      target = Factors::get( :cid => cid, :sid => sid )

      matches = Array::new()

      if target != nil

        matches.push( { :match => target, :dist => 0.0 } )

        result = target.to_s

        filters = nil

        target.each_match( :filters => filters ) { |match|
          
          dist = target.distance( match )

          next if (dist < 0)

          matches.push( { :match => match, :dist => dist } )

          result += "<br> " + match.to_s

        }

      end

    end

    if result.blank?

      result = 'Error: method needs valid cid, sid, datadata'

    end

    render :text => result

  end

  #
  # Method that returns details data for a particular ticker for detailed view
  #
  def details_for_ticker
  end

end

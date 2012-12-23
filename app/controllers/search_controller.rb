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

  #
<<<<<<< HEAD
  # Method that returns a list of comparable investmentments for a particular ticker
  #
  def comparables_for_ticker

    cid = params[:cid]
    sid = params[:sid]

    # TODO: support for querying on specific datadate instead of most recent
    # TODO: support for filters

    target    = nil
    distances = Array::new()
    result    = ""

    if !cid.blank? && !sid.blank?

      # get factors for the stock defined by sid, cid pair
      target = Factors::get( :cid => cid, :sid => sid )

      if !target.nil?

        # The target has no distance from itself. Push as the topmost element.
        distances.push( { :match => target, :dist => 0.0 } )

        result = target.to_s

        # filters are TBD arguments.
        filters = nil

        target.each_match( :filters => filters ) { |match|
          
          dist = target.distance( match )

          next if (dist < 0)

          distances.push( { :match => match, :dist => dist } )

          result += "<br> " + match.to_s

        }

      end

    end
    
    if (distances.length > 1)

      distances.sort! { |a,b| a[:dist] <=> b[:dist] }

      result_obj  = Array::new()
      cid_touched = Hash::new()

      distances.each { |item|

        cid    = item[:match].cid
        puts "cid=#{cid}"
        next if cid_touched.has_key?(cid)

        fields = item[:match].fields
        fields['distance'] = item[:dist]

        result_obj.push(fields)

        cid_touched[cid] = 1

      }


      render :json => result_obj.to_json

    elsif target.nil?

      render :text => 'Error: method needs valid cid, sid'

    elsif (distances.length == 1)

      render :text => 'Error: no matches found. Try another cid, sid pair'

    else

      render :text => 'Error: failed request'

    end

  end

  #
=======
>>>>>>> 97f9e8fda20e01ce8b3922ed57033a1c117e4d48
  # Method that returns details data for a particular ticker for detailed view
  #
  def details_for_ticker

  end

end

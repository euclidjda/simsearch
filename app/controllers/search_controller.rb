class SearchController < ApplicationController

  def search
    if !current_user || !current_user.has_role(Roles::Alpha)
      redirect_to "/"
    end
  end

  def autocomplete_investment_ticker
    term = params[:term]
    if term && !term.empty?
      items = Investment.select("distinct id, ticker as shortname, name as longname").
          where("LOWER(CONCAT(ticker, name)) like ?", '%' + term.downcase + '%').
          limit(10).order(:shortname)
    else
      items = {}
    end

    render :json => json_for_autocomplete(items, :shortname, [:id, :longname])
    
  end


  def ticker
  end
end

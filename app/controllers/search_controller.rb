class SearchController < ApplicationController

  def search
    if !current_user || !current_user.has_role(Roles::Alpha)
      redirect_to "/"
    end
  end

  def autocomplete_investment_ticker
    term = params[:term]
    if term && !term.empty?
      items = Investment.select("distinct id, ticker, name").
          where("LOWER(CONCAT(ticker, name)) like ?", '%' + term.downcase + '%').
          limit(10).order(:ticker)
    else
      items = {}
    end

    render :json => json_for_autocomplete(items, :ticker, [:id, :name])
    
  end


  def ticker
  end
end

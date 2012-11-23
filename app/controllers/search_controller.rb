class SearchController < ApplicationController

  def search
    if !current_user || !current_user.has_role(Roles::Alpha)
      redirect_to "/"
    end
  end

  def ticker
  end
end

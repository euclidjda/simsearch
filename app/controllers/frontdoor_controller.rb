class FrontdoorController < ApplicationController

  def root
    # always redirect to home, redundant actually since routes.rb also does this.
    redirect_to :action => :home
  end

  def login
  end

  def home
    # If the user has already established a session, no need to ask for auth again.
    if current_user
      redirect_to :action => :search
    end
  end

  def standby
  end

  def search
    # actual search content
  end

  def destroy_session
  end

  def create_session
  end

end

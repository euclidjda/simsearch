class FrontdoorController < ApplicationController

  def root
    if current_user
      redirect_to :action => :home
    else
      redirect_to :action => :login
    end
  end

  def login

  end

  def home

  end

  def standby
  end

  def destroy_session
  end

  def create_session
  end

end

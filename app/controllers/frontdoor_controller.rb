class FrontdoorController < ApplicationController

  def root
    # always redirect to home, redundant actually since routes.rb also does this.
    redirect_to :action => :home
  end

  def login
    mail_id = params[:mail_address_entry];

    # find the user, if not create one.
    user = User.create_with_email(mail_id)

    if user
      create_session user
    end

    redirect_to root_path, :notice => "Signed in"

  end

  def home
    # Home page rendering. There is not much as function here since most of the activity
    # is UI and that is handled in the view.

    if current_user

    end
  end

  def destroy_session
    session[:user_id] = nil
    redirect_to root_path, :notice => 'Signed out'
  end

  def create_session(user)
      session[:user_id] = user.id
  end

end

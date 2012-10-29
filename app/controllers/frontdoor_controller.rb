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

    redirect_to "/", :notice => "Signed in"

  end

  def home
    # If the user has already established a session, no need to ask for auth again.
    # If no session, then the default content will ask for login information.

    if current_user
      if current_user.has_role(Roles::Alpha)
        redirect_to "/search"
      else
        redirect_to "/standby"
      end
    end
  end

  def standby
  end

  def destroy_session
    session[:user_id] = nil
    redirect_to root_path, :notice => 'Signed out'
  end

  def create_session(user)
      session[:user_id] = user.id
  end

end

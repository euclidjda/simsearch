
module Roles
  Default = 0
  Alpha = 1
  Beta = 2
  Production = 3
  Admin = 4
end

class User < ActiveRecord::Base
=begin
  #if we use mongo / mongoid one day, we would use this notation. 

  field :uid, :type => String
  field :provider, :type => String
  field :email, :type => String
  field :name, :type => String
  field :first_name, :type => String
  field :last_name, :type => String
  field :oauth_token, :type => String
  field :role, :type => Integer
=end

  # Make all of our attributes bulk accessible to our code now since we don't
  # have a controller for user, this is safe.
  attr_accessible :uid, :provider, 
                  :email, :name, :first_name, :last_name, 
                  :oauth_token, 
                  :role

  # return the display name of the user.
  def display_name 
  	email
  end

  def self.create_with_email(_email)

    # try to find the user first
    user = find_by_email(_email)

    # If we could not find the user, we create one with the email, but we have no details.
    # This user is basically requesting access to the service. We will get his details through
    # a separate form later. When we do Google / LinkedIn, etc. auth, we will get name details from
    # those providers' profile of the user.
    if ! user

      logger.info "Creating user with email: " + _email

      user = create! do |user|
        user.email = _email
        user.provider = "manual"  # Indicating this was a manual user information entry.
      end
    end

    # return the user 
    user
  end

  def has_role(_role)
    if self['role'] == Roles::Default
        return false
    end

    # For superuser, all roles are valid.
    if self['role'] == [Roles::Admin]
        return true
    end

    # Return value based on parameter.
    return self['role'] == _role
  end

private

  def find_by_email(_email)
  
    logger.info "Looking up user with email: " + _email

  	begin
  	  return self.find_by(:mail => _email)
    rescue
 	    return nil
    end
  end

end

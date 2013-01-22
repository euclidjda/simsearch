# Roles to be used for authorization during various stages. 
module Roles
  Default = 0
  User = 1
  Admin = 2
end

class User < ActiveRecord::Base

  # Make all of our attributes bulk accessible to our code. 
  #Since we don't have a controller for user, this is safe.
  attr_accessible :provider, :role,
                  :email, :username, 
                  :password, :password_confirmation,
                  :password_hash,
                  :first_name, :last_name, 
                  :oauth_token

  # attribute password is virtual, it is not stored in the db.
  # password_confirmation is also virtual and automatically created since
  # we declare a validator for the password.
  attr_accessor :password

  #validates_confirmation_of :password
  #validates_presence_of :password, :on => :create

  validates :email, 
              :uniqueness => { :case_sensitive => false }, 
              :presence => true

  validates :username, 
              :uniqueness => { :case_sensitive => false },
              :presence => true
  validates :password,
              :presence => true,
              :confirmation => true,
              :length       => { :within => 6..30 }

  def self.create_with_form_data(args)
   # if args[:password].present?
    #  args[:password_salt] = "123"
    #  args[:password_hash] = "456"

    @user = create do |user|
      user.email = args[:email]
      user.username = args[:username]
      user.provider = "self"  
      user.role = Roles::User
      user.password = args[:password]
      user.password_hash = BCrypt::Password.create(user.password, :cost => 10)
    end

  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  # return the display name of the user.
  def display_name 
  	username
  end
  
  # create a user with given email and username
  # We assert that we are positive when calling this method that we do NOT have 
  # a user with the same username and mail address...
  def self.create_with_email_and_username(_email, _username)

    # try to find the user first
    begin 
      user = self.find_by_email_and_username(_email, _username)
    rescue
      user = nil
    end

    # If we could not find the user, we create one with the email, but we have no details.
    # This user is basically requesting access to the service. We will get his details through
    # a separate form later. When we do Google / LinkedIn, etc. auth, we will get name details from
    # those providers' profile of the user.
    if ! user

      logger.info "Creating user with email: " + _email

      user = create! do |user|
        user.email = _email
        user.provider = "self"  # Indicating that the authentication for this user is done by us.
      end
    end

    # return the user 
    user
  end

  def has_role(_role)
    if self['role'] == Roles::Default
        # This should never happen.
        return false
    end

    # For superuser, all roles are valid.
    if self['role'] == [Roles::Admin]
        return true
    end

    # Return value based on parameter.
    return self['role'] == _role
  end
end

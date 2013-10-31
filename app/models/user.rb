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

  # validates_confirmation_of :password
  # validates_presence_of :password, :on => :create

  validates :email, 
              :uniqueness => { :case_sensitive => false }, 
              :presence => true,
              :on => :create

  validates :username, 
              :presence => true
              
  validates :password,
              :presence => true,
              :confirmation => true,
              :length => { :within => 6..30 },
              :on => :create

  validates :password, 
              :confirmation => true,
              :length => {:within => 6..30},
              :allow_blank => true,
              :on => :update

  before_save :encrypt_password
  after_save :clear_password              

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
    end

  end

  # return the display name of the user.
  def display_name 
    username
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

  def match_password(input_password="")
    #remember the password from database.
    user_password = BCrypt::Password.new(password_hash)
    user_password == input_password
  end

private

  def encrypt_password
    if password.present?
      # self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Password.create(password, :cost => 10)
    end
  end

  def clear_password
    self.password = nil
  end
end

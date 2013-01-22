class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :role
      t.string :provider
      t.string :email
      t.string :username
      t.string :password_hash
      t.string :first_name
      t.string :last_name
      t.string :oauth_token

      t.timestamps
    end
  end
end

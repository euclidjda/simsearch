class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :role,          :null => false
      t.string :provider,       :null => false
      t.string :email,          :null => false
      t.string :username,       :null => false
      t.string :password_hash,  :null => false
      t.string :first_name
      t.string :last_name
      t.string :oauth_token

      t.timestamps
    end
  end
end

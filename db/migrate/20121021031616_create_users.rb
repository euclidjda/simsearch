class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uid
      t.integer :role
      t.string :provider
      t.string :email
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :oauth_token

      t.timestamps
    end
  end
end

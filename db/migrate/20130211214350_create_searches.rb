class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :cid
      t.string :sid
      t.date :pricedate
      t.date :fromdate
      t.date :thrudate
      t.integer :type_id
      t.integer :count
      t.integer :wins
      t.float :mean
      t.float :mean_under
      t.float :mean_over
      t.float :max
      t.float :min

      t.timestamps
    end
  end
end

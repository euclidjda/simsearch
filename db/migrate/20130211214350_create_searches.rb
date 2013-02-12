class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :cid
      t.string :sid
      t.date :pricedate
      t.date :fromdate
      t.date :thrudate
      t.string :search_type
      t.integer :completed

      t.timestamps
    end
  end
end

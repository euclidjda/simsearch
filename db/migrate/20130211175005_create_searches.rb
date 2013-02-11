class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :cid
      t.string :sid
      t.string :pricedate
      t.string :search_type

      t.timestamps
    end
  end
end

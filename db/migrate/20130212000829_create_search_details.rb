class CreateSearchDetails < ActiveRecord::Migration
  def change
    create_table :search_details do |t|
      t.integer :search_id
      t.string :cid
      t.string :sid
      t.date :pricedate
      t.float :dist
      t.float :stk_rtn
      t.float :mrk_rtn
    end
  end
end

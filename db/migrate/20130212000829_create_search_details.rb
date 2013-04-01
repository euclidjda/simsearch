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

    # foreign to help delete/cleanup
    execute <<-SQL
      ALTER TABLE search_details
        ADD CONSTRAINT 
        FOREIGN KEY (search_id)
        REFERENCES searches (id)
        ON DELETE CASCADE
    SQL

  end
end

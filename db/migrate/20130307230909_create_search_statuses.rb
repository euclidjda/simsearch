class CreateSearchStatuses < ActiveRecord::Migration
  def change
    create_table :search_statuses do |t|
      t.integer :search_id
      t.date :fromdate
      t.date :thrudate
      t.string :comment
      t.integer :num_steps
      t.integer :cur_step
      t.boolean :complete

      t.timestamps
    end

    # foreign to help delete/cleanup
    execute <<-SQL
      ALTER TABLE search_statuses
        ADD CONSTRAINT 
        FOREIGN KEY (search_id)
        REFERENCES searches (id)
        ON DELETE CASCADE
    SQL

    execute <<-SQL
      ALTER TABLE search_statuses
<<<<<<< HEAD
      ADD UNIQUE KEY uk_search_statuses (search_id,fromdate,thrudate)
=======
      ADD UNIQUE KEY idx_search_id (search_id,fromdate,thrudate)
>>>>>>> 86ff9c5d065ee5d6c2e128a846ba883d5e5bc0c9
    SQL

  end
end


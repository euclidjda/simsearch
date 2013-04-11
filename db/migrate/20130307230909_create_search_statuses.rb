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
      ADD UNIQUE KEY (search_id,fromdate,thrudate)
    SQL

  end
end


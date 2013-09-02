class CreateSearchActions < ActiveRecord::Migration
  def change
    create_table :search_actions do |t|

      t.integer :user_id
      t.integer :search_id
      t.integer :action_id
      t.integer :action_count

      t.timestamps
    end

    # foreign to help delete/cleanup
    execute <<-SQL
      ALTER TABLE search_actions
        ADD CONSTRAINT 
        FOREIGN KEY (search_id)
        REFERENCES searches (id)
        ON DELETE CASCADE
    SQL

  end
end

class CreateSearchActions < ActiveRecord::Migration
  def change
    create_table :search_actions do |t|

      t.integer :user_id
      t.integer :search_id
      t.integer :action_id
      t.integer :action_count

      t.timestamps
    end
  end
end

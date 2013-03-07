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
  end
end

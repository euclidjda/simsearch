class CreatePrioritySearches < ActiveRecord::Migration
  def change
    create_table :priority_searches do |t|
      t.string :ticker
      t.integer :priority

    end
  end
end

class CreateSearchTypes < ActiveRecord::Migration
  def change
    create_table :search_types do |t|
      t.string :factors
      t.string :weights
      t.string :gicslevel
      t.string :newflag

      t.timestamps
    end
  end
end

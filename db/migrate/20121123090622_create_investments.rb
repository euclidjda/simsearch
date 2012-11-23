class CreateInvestments < ActiveRecord::Migration
  def change
    create_table :investments do |t|
      t.string :ticker
      t.string :name

      t.timestamps
    end
  end
end

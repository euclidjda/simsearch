class CreateShareActivities < ActiveRecord::Migration
  def change
    create_table :share_activities do |t|

      t.integer :user_id
      t.integer :search_id
      t.string  :share_email
      t.string  :share_message

      t.timestamps
    end
  end
end

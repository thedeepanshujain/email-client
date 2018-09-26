class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :pending_messages
      t.string :replied_messages
      t.string :unassigned_messages
      t.string :transferred_messages
      t.integer :pending_count
      t.integer :replied_count
      t.integer :unassigned_count
      t.integer :transferred_count
      t.datetime :last_login_time
      t.datetime :last_activity_time
      t.string :last_history_id
      t.string :password_digest

      t.timestamps
    end
  end
end

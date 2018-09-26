class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.string :message_id
      t.string :assigned_to
      t.string :reply_to
      t.string :reply
      t.string :labels
      t.integer :status
      t.string :contact_email
      t.string :thread_id
      t.string :message_time
      t.string :assignment_id

      t.timestamps
    end
  end
end

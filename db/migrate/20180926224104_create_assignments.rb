class CreateAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :assignments do |t|
      t.datetime :assignment_time
      t.string :message_id
      t.string :assigned_to
      t.string :assigned_from
      t.integer :status

      t.timestamps
    end
  end
end

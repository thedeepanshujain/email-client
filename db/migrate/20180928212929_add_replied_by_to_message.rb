class AddRepliedByToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :replied_by, :string
  end
end

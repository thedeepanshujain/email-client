class AddSnippetToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :snippet, :string
  end
end

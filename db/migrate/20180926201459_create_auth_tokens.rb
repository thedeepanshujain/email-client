class CreateAuthTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :auth_tokens do |t|
      t.string :refresh_token
      t.string :access_token
      t.datetime :expires_at

      t.timestamps
    end
  end
end

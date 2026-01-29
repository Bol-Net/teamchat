class CreateRefreshTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :refresh_tokens do |t|
      t.string :token
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at
      t.boolean :revoked, default: false
      t.string :ip
      t.text :user_agent

      t.timestamps
    end
  end
end

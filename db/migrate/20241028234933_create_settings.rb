class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings do |t|
      t.belongs_to :user, foreign_key: true
      t.string :app_name
      t.string :api_key
      t.string :secret_key
      t.string :token
      t.timestamps
    end
  end
end

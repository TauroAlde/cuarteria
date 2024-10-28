class AddUserToExternalApiUrls < ActiveRecord::Migration[7.1]
  def change
    add_reference :external_api_urls, :user, null: false, foreign_key: true
  end
end

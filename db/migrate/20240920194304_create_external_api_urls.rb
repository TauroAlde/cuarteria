class CreateExternalApiUrls < ActiveRecord::Migration[7.1]
  def change
    create_table :external_api_urls do |t|
      t.string :name
      t.string :url
      t.text :description
      t.boolean :active

      t.timestamps
    end
  end
end

class AddSetingsToUser < ActiveRecord::Migration[7.1]
  def change
    add_reference  :users, :setting, foreign_key: true
  end
end

class AddUserToProfiles < ActiveRecord::Migration[8.1]
  def change
    add_reference :profiles, :user, null: false, foreign_key: true
    add_index :profiles, :user_id, unique: true, if_not_exists: true
  end
end

class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.text :information
      t.string :picture_url

      t.timestamps
    end
  end
end

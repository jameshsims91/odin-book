class AddDemoAccountToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :demo_account, :boolean,
               default: false, null: false
  end
end

class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :display_name
      t.integer :admin, null: false, default: 2

      t.timestamps
    end
  end
end

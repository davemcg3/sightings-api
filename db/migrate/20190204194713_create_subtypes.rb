class CreateSubtypes < ActiveRecord::Migration[5.2]
  def change
    create_table :subtypes do |t|
      t.string :name, null: false
      t.references :subject, null: false, foreign_key: true

      t.timestamps
    end
  end
end

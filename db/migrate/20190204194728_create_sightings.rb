class CreateSightings < ActiveRecord::Migration[5.2]
  def change
    create_table :sightings do |t|
      t.references :subject, null: false, foreign_key: true
      t.references :subtype, foreign_key: true
      t.integer :zipcode, null: false
      t.text :notes
      t.integer :number_sighted

      t.timestamps
    end
  end
end

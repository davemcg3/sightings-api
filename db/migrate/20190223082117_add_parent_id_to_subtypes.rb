class AddParentIdToSubtypes < ActiveRecord::Migration[5.2]
  def change
    add_reference :subtypes, :parent, foreign_key: { to_table: :subtypes }
  end
end

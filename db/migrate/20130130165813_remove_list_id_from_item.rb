class RemoveListIdFromItem < ActiveRecord::Migration
  def up
    remove_column :items, :list_id
  end

  def down
    add_column :items, :list_id, :integer
  end
end

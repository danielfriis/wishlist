class AddViaToItems < ActiveRecord::Migration
  def change
    add_column :items, :via, :string, :default => "default"
  end
end

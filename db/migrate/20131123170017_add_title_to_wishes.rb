class AddTitleToWishes < ActiveRecord::Migration
  def change
    add_column :wishes, :title, :string
  end
end

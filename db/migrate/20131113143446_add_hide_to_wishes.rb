class AddHideToWishes < ActiveRecord::Migration
  def change
    add_column :wishes, :hide, :boolean, default: false
  end
end

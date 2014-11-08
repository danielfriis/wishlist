class AddAvatarToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :avatar, :string
  end
end

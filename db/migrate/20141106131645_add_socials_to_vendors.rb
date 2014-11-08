class AddSocialsToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :bio, :text
    add_column :vendors, :twitter, :string
    add_column :vendors, :instagram, :string
    add_column :vendors, :pinterest, :string
    add_column :vendors, :facebook, :string
  end
end

class AddGenderToItems < ActiveRecord::Migration
  def change
    add_column :items, :gender, :string
  end
end

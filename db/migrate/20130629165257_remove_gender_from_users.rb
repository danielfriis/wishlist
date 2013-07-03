class RemoveGenderFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :gender
  end

  def down
    add_column :users, :gender, :integer
  end
end

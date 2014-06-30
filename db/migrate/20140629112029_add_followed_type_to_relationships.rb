class AddFollowedTypeToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :followed_type, :string
    add_index :relationships, :followed_type
  end
end

class AddIndexToFollowerIdAndFolledIdInRelationships < ActiveRecord::Migration
  def change
  	add_index :relationships, [:follower_id, :followed_id, :followed_type], unique: true, name: 'follower_id_followed_id_and_type_index'
  end
end

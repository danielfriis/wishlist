class RemoveIndexFromFollowerIdAndFollowedIdInRelationship < ActiveRecord::Migration
  def up
  	remove_index :relationships, [:follower_id, :followed_id]
  end

  def down
  	add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end

class AddFollowerNotificationAndCommentNotificationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :follower_notification, :boolean, default: true
    add_column :users, :comment_notification, :boolean, default: true
  end
end

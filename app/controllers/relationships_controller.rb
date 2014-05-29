class RelationshipsController < ApplicationController
  before_filter :signed_in_user
  include Analyzable

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    tracker.track("Followed another user")
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    tracker.track("Unfollowed another user")
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
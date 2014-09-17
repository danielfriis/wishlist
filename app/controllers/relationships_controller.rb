class RelationshipsController < ApplicationController
  before_filter :signed_in_user
  include Analyzable

  def create
    subject_class = params[:relationship][:followed_type].classify.constantize
    @subject = subject_class.find(params[:relationship][:followed_id])
    relationship = current_user.relationships.create!(followed_id: @subject.id, followed_type: @subject.class.name)
    track_activity relationship
    tracker.track(current_user.id, "Followed another #{@subject.class.name}")
    if @subject.class.name == "User" && @subject.follower_notification?
      UserMailer.delay.new_follower(current_user.id, @subject.id)
    end
    respond_to do |format|
      format.html { redirect_to @subject }
      format.js
    end
  end

  def destroy
    @subject = Relationship.find(params[:id]).followed
    current_user.relationships.find_by_followed_id_and_followed_type(@subject.id, @subject.class.name).destroy
    tracker.track(current_user.id, "Unfollowed another #{@subject.class.name}")
    respond_to do |format|
      format.html { redirect_to @subject }
      format.js
    end
  end

private

  def correct_user
    @comment = current_user.comments.find_by_id(params[:id])
    redirect_to current_user if @comment.nil?
  end
end

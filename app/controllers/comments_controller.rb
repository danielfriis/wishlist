class CommentsController < ApplicationController
  before_filter :signed_in_user
	before_filter :get_commentable
  before_filter :correct_user,   only: :destroy

  def index
  	@comments = @commentable.comments
  end

  def new
    @comment = @commentable.comments.new
  end

  def create
    @comment = @commentable.comments.new(params[:comment])
    if @comment.save
      if @commentable.class.name == "Wish" && @commentable.list.user.comment_notification?
        UserMailer.delay.new_comment(current_user.id, @commentable.list.user.id, @commentable.id, @comment.id)
      end
      redirect_to @commentable, notice: "Comment created."
    else
      redirect_to @commentable
    end
  end

  def destroy
    @comment.destroy
    redirect_to @commentable
  end

private

	def get_commentable
    @commentable = params[:commentable].classify.constantize.find(commentable_id)
  end

  def commentable_id
    params[(params[:commentable].singularize + "_id").to_sym]
  end

  def correct_user
    @comment = current_user.comments.find_by_id(params[:id])
    redirect_to current_user if @comment.nil?
  end
end

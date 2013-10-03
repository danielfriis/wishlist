class CommentsController < ApplicationController
	before_filter :load_commentable
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

	def load_commentable
		resource, id = request.path.split('/')[1, 2]
		@commentable = resource.singularize.classify.constantize.find(id)
	end

  def correct_user
    @comment = current_user.comments.find_by_id(params[:id])
    redirect_to current_user if @comment.nil?
  end
end

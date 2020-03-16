class PostCommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @comment = PostComment.new( post_comment_params )
    @comment.save
  end

  private
  def post_comment_params
    { user_id: current_user.id, pattern_id: params[ :pattern_id ], body: params[ :body ] }
  end
end

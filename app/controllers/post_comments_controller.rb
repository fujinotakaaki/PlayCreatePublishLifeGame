class PostCommentsController < ApplicationController
  before_action :authenticate_user!, except: [ :show ]

  # 非同期通信
  def show
    # 対象パターンへの全コメント取得
    @comments = PostComment.where( pattern_id: params[ :pattern_id ] ).reverse_order
  end

  def create
    @comment = current_user.post_comments.build( post_comment_params )
    @comment.pattern_id = params[ :pattern_id ]
    @comment.save
  end


  private

  def post_comment_params
    params.require( :post_comment ).permit( :body )
  end
end

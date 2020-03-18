class FavoritesController < ApplicationController
  before_action :authenticate_user!

  # お気に入り登録
  def create
    favorite = Favorite.new( user_id: current_user.id, pattern_id: params[ :pattern_id ] )
    favorite.save
    @pattern_id = params[ :pattern_id ]
  end

  # お気に入り解除
  def destroy
    favorite = Favorite.find_by( user_id: current_user.id, pattern_id: params[ :pattern_id ] )
    favorite.destroy
    @pattern_id = params[ :pattern_id ]
  end
end

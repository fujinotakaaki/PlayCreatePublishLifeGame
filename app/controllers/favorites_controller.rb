class FavoritesController < ApplicationController
  def create
    favorite = Favorite.new( user_id: current_user.id, pattern_id: params[ :pattern_id ] )
    favorite.save
    @pattern_id = params[ :pattern_id ]
  end

  def destroy
    favorite = Favorite.find_by( user_id: current_user.id, pattern_id: params[ :pattern_id ] )
    favorite.destroy
    @pattern_id = params[ :pattern_id ]
  end
end

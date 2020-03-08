class CategoriesController < ApplicationController
  def index
    # 全データ取得
    @categories = Category.all
  end

  def show
    # 詳細データ取得
    @category = Category.find( params[ :id ] )
  end
end

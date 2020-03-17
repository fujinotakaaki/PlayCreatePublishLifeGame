class CategoriesController < ApplicationController
  def index
    # 全データ取得
    @categories = Category.all
  end

  def show
    # カテゴリ別の投稿を取得
    @category_name = Category.find( params[ :id ]).name
    @patterns = Pattern.where( category_id: params[ :id ] ).page( params[ :page ] ).reverse_order
    render 'patterns/index'
  end
end

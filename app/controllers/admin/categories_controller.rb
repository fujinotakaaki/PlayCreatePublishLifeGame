class Admin::CategoriesController < Admin::ApplicationController

  def index
    # カテゴリ一覧取得
    @categories = Category.all
    @category = Category.new
  end

  def create
    # 新規カテゴリの登録
    @category = Category.new( category_params )
    @category.save
  end

  def edit
    # 編集するカテゴリ情報の取得
    @category = Category.find( params[:id] )
  end

  def update
    # 編集するカテゴリの情報を更新
    @category = Category.find( params[:id] )
    @category.update( category_params )
  end

  def destroy
    # 削除するカテゴリの情報を更新
    @category = Category.find( params[:id] )
    # 削除するカテゴリが使用されているか判定
    @is_used = @category.patterns.exists?
    # 未使用であれば削除実行
    @category.destroy unless @is_used
  end

  private

  def category_params
    params.require( :category ).permit( :name, :explanation )
  end
end

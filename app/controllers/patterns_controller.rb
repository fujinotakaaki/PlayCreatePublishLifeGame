class PatternsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]

  def index
    @patterns = Pattern.all.page(params[:page]).reverse_order
  end

  def create
  end

  def edit
  end

  def show
  end

  def update
  end

  def destroy
  end
end

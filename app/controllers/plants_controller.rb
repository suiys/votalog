class PlantsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :show, :destroy]

  def new
    @plant = Plant.new
  end

  def create
    @plant = Plant.new(plant_params)
    @plant.user = current_user
    if @plant.save
      redirect_to plant_path(@plant), notice: "#{@plant.name}をマイ多肉棚に追加しました"
    else
      flash.now[:alert] = '新しい株の登録に失敗しました'
      render "new"
    end
  end

  def show
    @user = current_user
    @plant = Plant.find(params[:id])
  end

  def edit
    @plant = Plant.find(params[:id])
  end

  def update
    @plant = Plant.find(params[:id])
    respond_to do |format|
      if @plant.update(plant_params)
        format.html { redirect_to @plant }
        format.js
      else
        format.html { render :edit }
        format.js { render :errors }
      end
    end
  end

  def destroy
    @plant = Plant.find(params[:id])
    @plant.destroy
    redirect_to root_path, notice: "#{@plant.name}を削除しました"
  end

  def plant_params
    params.require(:plant).permit(:name, :next_water_day, :next_fertilizer_day, :next_replant_day, :image)
  end

  def ensure_correct_user
    plant = Plant.find(params[:id])
    unless plant.user == current_user
      redirect_to root_path, alert: "自分が所持している株以外の参照・編集・削除等の操作は行えません"
    end
  end
end

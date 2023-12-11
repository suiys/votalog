class PlantsController < ApplicationController
  before_action :authenticate_user!

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
  end

  def plant_params
    params.require(:plant).permit(:name, :next_water_day, :next_fertilizer_day, :next_replant_day, :image)
  end
end

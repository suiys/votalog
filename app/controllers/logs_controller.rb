class LogsController < ApplicationController
  before_action :authenticate_user!

  def new
    @log = Log.new
  end

  def create
    @log = Log.new(log_params)
    @log.user = current_user
    if @log.save
      redirect_to log_path(@log), notice: "新しいログを保存しました"
    else
      flash.now[:alert] = "新しいログの保存に失敗しました"
      render "new"
    end
  end

  def show
    @log = Log.find(params[:id])
  end

  def edit
    @log = Log.find(params[:id])
  end

  def update
    @log = Log.find(params[:id])
    if @log.update(log_params)
      redirect_to plant_path(@log.plant), notice: "ログを更新しました"
    else
      flash.now[:alert] = "ログの更新に失敗しました"
      render "edit"
    end
  end

  def destroy
  end

  def log_params
    params.require(:log).permit(:start_time, :is_watered, :is_fertilized, :is_replanted, :memo, :image, :temperature, :humidity, :light_start_at, :light_end_at, :plant_id)
  end
end

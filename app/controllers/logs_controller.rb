class LogsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :show, :destroy]

  def new
    @log = Log.new
    @user = current_user
    if @user.latitude && @user.longitude
      @temperature, @humidity = Log.get_weather_info(@user.latitude, @user.longitude)
      if @temperature.nil? || @humidity.nil?
        flash.now[:alert] = "気象情報の取得に失敗しました"
      end
    else
      @temperature = nil
      @humidity = nil
    end
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
      redirect_to log_path(@log), notice: "ログを更新しました"
    else
      flash.now[:alert] = "ログの更新に失敗しました"
      render "edit"
    end
  end

  def destroy
    @log = Log.find(params[:id])
    @log.destroy
    redirect_to plant_path(@log.plant), notice: "ログを削除しました"
  end

  private

    def log_params
      params.require(:log).permit(:start_time, :is_watered, :is_fertilized, :is_replanted, :memo, :image, :temperature, :humidity, :light_start_at, :light_end_at, :plant_id)
    end

    def ensure_correct_user
      log = Log.find(params[:id])
      unless log.user == current_user
        redirect_to root_path, alert: "自分のお世話ログ以外の参照・編集・削除等の操作は行えません"
      end
    end
end

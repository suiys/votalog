class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(current_user.id)
  end

  def settings
    @user = User.find(current_user.id)
  end

  def edit
    @user = User.find(current_user.id)
  end

  def update
    @user = User.find(params[:id])
    if params[:user][:zipcode].present?
      @user.latitude, @user.longitude = User.get_users_location(params[:user][:zipcode])
      if @user.latitude && @user.longitude
        if @user.update(user_params)
          redirect_to users_settings_path, notice: "ユーザー設定を更新しました"
        else
          flash.now[:alert] = "ユーザー設定の更新に失敗しました"
          render "edit"
        end
      else
        redirect_to users_settings_edit_path, alert: "位置情報の取得に失敗しました。郵便番号が誤っていないか確認してください"
      end
    elsif @user.zipcode
      @user.latitude = nil
      @user.longitude = nil
      if @user.update(user_params)
        redirect_to users_settings_path, notice: "ユーザー設定を更新しました"
      else
        flash.now[:alert] = "ユーザー設定の更新に失敗しました"
        render "edit"
      end
    else
      redirect_to users_settings_path
    end
  end

  def user_params
    params.require(:user).permit(:zipcode, :latitude, :longitude)
  end
end

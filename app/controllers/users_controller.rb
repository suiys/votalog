class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: :update

  def show
    @user = User.find(current_user.id)
  end

  def settings
    @user = User.find(current_user.id)
    if @user.zipcode
      format_zipcode = format("%07d", @user.zipcode).to_s
      @zipcode = format_zipcode.slice(0..2) + " - " + format_zipcode.slice(3..6)
    end
  end

  def edit
    @user = User.find(current_user.id)
  end

  def update
    @user = User.find(params[:id])
    if params[:user][:zipcode].present?
      @user.latitude, @user.longitude = @user.get_users_location(params[:user][:zipcode])
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

  private

    def user_params
      params.require(:user).permit(:zipcode, :latitude, :longitude)
    end

    def ensure_correct_user
      user = User.find(params[:id])
      unless user == current_user
        redirect_to users_settings_path, alert: "自分のユーザー設定以外の変更は行えません"
      end
    end
end

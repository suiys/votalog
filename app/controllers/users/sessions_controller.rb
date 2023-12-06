class Users::SessionsController < Devise::SessionsController
  def guest_sign_in
    user = User.find_or_create_guest_user
    sign_in user
    redirect_to root_path, notice: 'ゲストユーザーとしてログインしました。'
  end
end

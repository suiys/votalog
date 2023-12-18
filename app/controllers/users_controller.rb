class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(current_user.id)
  end

  def settings
    @user = User.find(current_user.id)
  end

  def edit
  end

  def update
  end
end

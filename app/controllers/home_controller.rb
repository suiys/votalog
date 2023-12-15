class HomeController < ApplicationController
  def index
    if user_signed_in?
      @user = current_user
      @todays_water_scheduled_plants = Plant.search_todays_schedules(@user, "water")
      @todays_fertilizer_scheduled_plants = Plant.search_todays_schedules(@user, "fertilizer")
      @todays_replant_scheduled_plants = Plant.search_todays_schedules(@user, "replant")
      @tomorrows_water_scheduled_plants = Plant.search_tomorrows_schedules(@user, "water")
      @tomorrows_fertilizer_scheduled_plants = Plant.search_tomorrows_schedules(@user, "fertilizer")
      @tomorrows_replant_scheduled_plants = Plant.search_tomorrows_schedules(@user, "replant")
    end
  end
end

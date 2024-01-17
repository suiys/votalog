class HomeController < ApplicationController
  MAX_RESULT_COUNT = 5

  def index
    if user_signed_in?
      @user = current_user
      @todays_water_scheduled_plants = Plant.search_todays_schedules(@user, "water")
      @todays_fertilizer_scheduled_plants = Plant.search_todays_schedules(@user, "fertilizer")
      @todays_replant_scheduled_plants = Plant.search_todays_schedules(@user, "replant")
      @future_water_scheduled_plants = Plant.search_future_schedules(@user, "water").limit(MAX_RESULT_COUNT)
      @future_fertilizer_scheduled_plants = Plant.search_future_schedules(@user, "fertilizer").limit(MAX_RESULT_COUNT)
      @future_replant_scheduled_plants = Plant.search_future_schedules(@user, "replant").limit(MAX_RESULT_COUNT)
    end
  end
end

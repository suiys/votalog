require 'rails_helper'

RSpec.describe Plant, type: :model do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }

  describe "バリデーション関連のテスト" do
    let(:plant) { build(:plant) }
    let(:plant_without_name) { build(:plant, name: nil) }
    let(:plant_with_png_image) { build(:plant_with_png_image) }
    let(:plant_with_jpg_image) { build(:plant_with_jpg_image) }
    let(:plant_with_gif_image) { build(:plant_with_gif_image) }
    let(:plant_with_text) { build(:plant_with_text) }

    it "株名称があればバリデーションをパスすること" do
      expect(plant).to be_valid
    end

    it "株名称がないとバリデーションをパスしないこと" do
      plant_without_name.valid?
      expect(plant_without_name.errors[:name]).to include "を入力してください"
    end

    it "PNGイメージをPlantモデルにアタッチできること" do
      expect(plant_with_png_image).to be_valid
    end

    it "JPEGイメージをPlantモデルにアタッチできること" do
      expect(plant_with_jpg_image).to be_valid
    end

    it "GIFイメージをPlantモデルにアタッチできること" do
      expect(plant_with_gif_image).to be_valid
    end

    it "textファイルはPlantモデルにアタッチできないこと" do
      plant_with_text.valid?
      expect(plant_with_text.errors[:image]).to include "には拡張子が.png, .jpg, .gifのいずれかのファイルを添付してください"
    end
  end

  describe ".search_todays_schedules" do
    let!(:target_plant_to_water_today) do
      create_list(:plant, 2, next_water_day: Time.zone.today, user: user)
    end
    let!(:not_target_user_plant_to_water_today) do
      create(:plant, next_water_day: Time.zone.today, user: another_user)
    end
    let!(:not_target_date_plant_to_water) do
      create(:plant, next_water_day: Time.zone.tomorrow, user: user)
    end
    let!(:plant_to_fertilize_today) do
      create(:plant, next_fertilizer_day: Time.zone.today, user: user)
    end
    let!(:plant_to_replant_today) { create(:plant, next_replant_day: Time.zone.today, user: user) }

    it "今日水やり予定の株が全て抽出できていること" do
      expect(Plant.search_todays_schedules(user, "water")).to match_array target_plant_to_water_today
    end
  end

  describe ".search_future_schedules" do
    let!(:target_plant_to_water_future) do
      [
        create(:plant, next_water_day: Time.zone.tomorrow, user: user),
        create(:plant, next_water_day: Time.zone.tomorrow + 1.day, user: user),
        create(:plant, next_water_day: Time.zone.tomorrow + 2.day, user: user),
      ]
    end
    let!(:not_target_user_plant_to_water_tomorrow) do
      create(:plant, next_water_day: Time.zone.tomorrow, user: another_user)
    end
    let!(:not_target_date_plant_to_water) do
      create(:plant, next_water_day: Time.zone.today, user: user)
    end
    let!(:plant_to_fertilize_tomorrow) do
      create(:plant, next_fertilizer_day: Time.zone.tomorrow, user: user)
    end
    let!(:plant_to_replant_tomorrow) do
      create(:plant, next_replant_day: Time.zone.tomorrow, user: user)
    end

    it "明日以降水やり予定の株が過不足なく抽出できていること" do
      expect(Plant.search_future_schedules(user, "water")).to match_array target_plant_to_water_future
    end
  end
end

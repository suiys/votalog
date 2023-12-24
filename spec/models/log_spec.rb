require 'rails_helper'

RSpec.describe Log, type: :model do
  let(:log) { create(:log) }

  describe "バリデーション関連のテスト" do
    let(:log_without_start_time) { build(:log, start_time: nil) }
    let(:log_with_memo) { build(:log, memo: "a" * 300) }
    let(:log_with_too_long_memo) { build(:log, memo: "a" * 301) }
    let(:log_with_not_numeric_temp) { build(:log, temperature: "０") }
    let(:log_with_humidity_less_than_zero_percent) { build(:log, humidity: -1) }
    let(:log_with_humidity_zero_percent) { build(:log, humidity: 0) }
    let(:log_with_humidity_a_handred_percent) { build(:log, humidity: 100.0) }
    let(:log_with_humidity_more_than_a_handred_percent) { build(:log, humidity: 100.1) }
    let(:log_with_png_image) { build(:log_with_png_image) }
    let(:log_with_jpg_image) { build(:log_with_jpg_image) }
    let(:log_with_gif_image) { build(:log_with_gif_image) }
    let(:log_with_text) { build(:log_with_text) }
    let(:log_with_light_end_at_after_start) { build(:log,light_start_at: Time.zone.now, light_end_at: Time.zone.now + 1.day) }
    let(:log_with_light_end_at_before_start) { build(:log,light_start_at: Time.zone.now, light_end_at: Time.zone.now - 1.day) }

    it "ログの記録日があればバリデーションをパスすること" do
      expect(log).to be_valid
    end

    it "ログ記録日がないとバリデーションをパスしないこと" do
      log_without_start_time.valid?
      expect(log_without_start_time.errors[:start_time]).to include "を入力してください"
    end

    it "300文字以内のメモが残せること" do
      expect(log_with_memo).to be_valid
    end

    it "300文字を超えるメモが残せないこと" do
      log_with_too_long_memo.valid?
      expect(log_with_too_long_memo.errors[:memo]).to include "は300文字以内で入力してください"
    end

    it "全角の数字を気温として入力できないこと" do
      log_with_not_numeric_temp.valid?
      expect(log_with_not_numeric_temp.errors[:temperature]).to include "は数値で入力してください"
    end

    it "0%未満の湿度を入力できないこと" do
      log_with_humidity_less_than_zero_percent.valid?
      expect(log_with_humidity_less_than_zero_percent.errors[:humidity]).to include "は0以上の値にしてください"
    end

    it "0%以上の湿度を入力できること" do
      expect(log_with_humidity_zero_percent).to be_valid
    end

    it "100%以下の湿度を入力できること" do
      expect(log_with_humidity_a_handred_percent).to be_valid
    end

    it "100%を超える湿度を入力できないこと" do
      log_with_humidity_more_than_a_handred_percent.valid?
      expect(log_with_humidity_more_than_a_handred_percent.errors[:humidity]).to include "は100以下の値にしてください"
    end

    it "PNGイメージをLogモデルにアタッチできること" do
      expect(log_with_png_image).to be_valid
    end

    it "JPEGイメージをLogモデルにアタッチできること" do
      expect(log_with_jpg_image).to be_valid
    end

    it "GIFイメージをLogモデルにアタッチできること" do
      expect(log_with_gif_image).to be_valid
    end

    it "textファイルはLogモデルにアタッチできないこと" do
      log_with_text.valid?
      expect(log_with_text.errors[:image]).to include "には拡張子が.png, .jpg, .gifのいずれかのファイルを添付してください"
    end

    it "植物育成ライトの点灯時刻が消灯時刻よりも早ければバリデーションをパスすること" do
      expect(log_with_light_end_at_after_start).to be_valid
    end

    it "植物育成ライトの点灯時刻が消灯時刻よりも遅ければバリデーションをパスしないこと" do
      log_with_light_end_at_before_start.valid?
      expect(log_with_light_end_at_before_start.errors[:light_end_at]).to include "は点灯時刻よりも後の時刻を入力してください"
    end
  end

  describe "#get_weather_info" do
    let(:user) { create(:user, latitude: 34.948035, longitude: 135.767568) }
    let(:log) { create(:log, user: user) }

    it "ユーザーが位置情報を登録している場合、OpenWeatherMapに位置情報を含むGETリクエストを送信しエラーなくレスポンスが取得できること" do
      expect{
        log.get_weather_info(user.latitude, user.longitude)
      }.not_to raise_error
    end
  end
end

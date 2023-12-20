class Log < ApplicationRecord
  require 'httpclient'
  validates :start_time, presence: true
  validates :memo, length: { maximum: 300 }
  validates :temperature, numericality: true, allow_nil: true
  validates :humidity, numericality: { in: 0..100 }, allow_nil: true
  validate :is_file_type_valid?
  validate :is_light_end_at_after_light_start_at?

  belongs_to :user
  belongs_to :plant

  has_one_attached :image

  def is_file_type_valid?
    return unless image.attached?

    valid_file_types = ["image/png", "image/jpg", "image/gif"]
    unless valid_file_types.include?(image.blob.content_type)
      errors.add(:image, "には拡張子が.png, .jpg, .gifのいずれかのファイルを添付してください")
    end
  end

  def is_light_end_at_after_light_start_at?
    if light_end_at.present? && light_end_at < light_start_at
      errors.add(:light_end_at, "は点灯時刻よりも後の時刻を入力してください")
    end
  end

  def get_weather_info(latitude, longitude)
    client = HTTPClient.new
    url = "https://api.openweathermap.org/data/2.5/weather?lat=" + latitude.to_s + "&lon=" + longitude.to_s + "&units=metric&appid=" + ENV['OPEN_WEATHER_API_KEY']
    response = client.get(url)
    res = JSON.parse(response.body)
    begin
      temperature = res["main"]["temp"]
      humidity = res["main"]["humidity"]
    rescue => e
      logger.error("気象情報の取得に失敗しました。エラー: #{e}")
      temperature = nil
      humidity = nil
    end
    return temperature, humidity
  end
end

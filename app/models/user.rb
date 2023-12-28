class User < ApplicationRecord
  require 'httpclient'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :name, presence: true
  validates :zipcode, length: { in: 5..7 }, numericality: { only_integer: true }, allow_nil: true

  has_many :plants, dependent: :destroy
  has_many :logs, dependent: :destroy

  def self.find_or_create_guest_user
    find_or_create_by!(email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = "ゲストユーザー"
    end
  end

  def format_zipcode(zipcode)
    seven_digits_zipcode = format("%07d", zipcode).to_s
    formatted_zipcode = seven_digits_zipcode.slice(0..2) + " - " + seven_digits_zipcode.slice(3..6)
  end

  def get_users_location(zipcode)
    client = HTTPClient.new
    url = "https://geoapi.heartrails.com/api/json?method=searchByPostal&postal=" + zipcode
    response = client.get(url)
    res = JSON.parse(response.body)
    begin
      latitude = res["response"]["location"][0]["y"]
      longitude = res["response"]["location"][0]["x"]
    rescue => e
      logger.error("位置情報の取得に失敗しました。エラー: #{e}")
      latitude = nil
      longitude = nil
    end
    [latitude, longitude]
  end
end

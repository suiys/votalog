class Plant < ApplicationRecord
  validates :name, presence: true
  validate :is_file_type_valid?
  validate :is_next_water_day_after_today?
  validate :is_next_fertilizer_day_after_today?
  validate :is_next_replant_day_after_today?

  belongs_to :user
  has_many :logs, dependent: :destroy

  has_one_attached :image

  def is_file_type_valid?
    return unless image.attached?

    valid_file_types = ["image/png", "image/jpg", "image/gif"]
    unless valid_file_types.include?(image.blob.content_type)
      errors.add(:image, "には拡張子が.png, .jpg, .gifのいずれかのファイルを添付してください")
    end
  end

  def is_next_water_day_after_today?
    if next_water_day.present? && next_water_day < Time.zone.today
      errors.add(:next_water_day, "は今日以降の日付を選択してください")
    end
  end

  def is_next_fertilizer_day_after_today?
    if next_fertilizer_day.present? && next_fertilizer_day < Time.zone.today
      errors.add(:next_fertilizer_day, "は今日以降の日付を選択してください")
    end
  end

  def is_next_replant_day_after_today?
    if next_replant_day.present? && next_replant_day < Time.zone.today
      errors.add(:next_replant_day, "は今日以降の日付を選択してください")
    end
  end

  def self.search_todays_schedules(user, params)
    Plant.where("user_id = ? and next_#{params}_day = ?", user.id, Time.zone.today)
  end

  def self.search_tomorrows_schedules(user, params)
    Plant.where("user_id = ? and next_#{params}_day = ?", user.id, Time.zone.tomorrow)
  end
end

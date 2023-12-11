class Log < ApplicationRecord
  validates :start_time, presence: true
  validates :memo, length: { maximum: 300 }
  validates :temperature, numericality: true
  validates :humidity, numericality: { in: 0..100 }
  validates :light_end_at, comparison: { greater_than: :light_start_at, message: "植物育成ライト消灯時刻は点灯時刻よりも後の時刻を入力してください" }
  validate :is_file_type_valid?

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
end

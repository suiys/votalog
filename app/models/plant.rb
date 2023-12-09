class Plant < ApplicationRecord
  validates :name, presence: true
  validate :is_file_type_valid?

  belongs_to :user

  has_one_attached :image

  def is_file_type_valid?
    return unless image.attached?

    valid_file_types = ["image/png", "image/jpg", "image/gif"]
    unless valid_file_types.include?(image.blob.content_type)
      errors.add(:image, "には拡張子が.png, .jpg, .gifのいずれかのファイルを添付してください")
    end
  end
end

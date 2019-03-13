class ValidCover < ActiveModel::Validator
  def validate( record )
    if record.cover_image.attached?
      begin
        MiniMagick::Image.read(record.cover_image.download).valid?
      rescue
        record.errors[:cover_image] << 'Invalid cover image'
        return false
      end
    end
  end
end
class Hide < ApplicationRecord
  #include ActiveModel::Validations
  has_one_attached :cover_image
  #validates_with ValidCover
  has_one_attached :message
  has_one_attached :stego_result
end


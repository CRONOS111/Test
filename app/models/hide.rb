
class Hide < ApplicationRecord
  #include ActiveModel::Validations
  has_one_attached :cover_image
  #validates_with ValidCover
  has_one_attached :message
  has_one_attached :stego_result
end


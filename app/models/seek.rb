class Seek < ApplicationRecord
  has_one_attached :stego
  has_one_attached :message
end

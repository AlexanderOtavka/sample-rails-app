class Image < ApplicationRecord
  validates :title, presence: true, length: { maximum: 50 }
  validates :url, presence: true, length: { maximum: 2083 }
  validates :aspect_ratio, presence: true
end

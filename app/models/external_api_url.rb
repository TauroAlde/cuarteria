class ExternalApiUrl < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :url, presence: true, format: { with: URI::regexp, message: "must be a valid URL" }
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }

  def self.get_url(name, user)
    active.where(user: user).find_by(name: name)&.url
  end
end

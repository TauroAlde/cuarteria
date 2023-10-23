class User < ApplicationRecord
  before_validation { self.email = email.downcase }

  has_secure_password
  validates :email, presence: true, uniqueness: true
end

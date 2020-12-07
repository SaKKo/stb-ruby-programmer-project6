class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_validation :generate_jti, on: [:create]

  validates :first_name, presence: true

  def generate_jti(force = false)
    self.jti = SecureRandom.urlsafe_base64 if force || self.jti.blank?
  end

  def jwt(exp = 1.days.from_now)
    payload = {
      exp: exp.to_i,
      jti: self.jti
    }
    JWT.encode payload, Rails.application.credentials.secret_key_base, 'HS256'
  end
end

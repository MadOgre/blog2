class User < ActiveRecord::Base
	before_create :confirmation_token
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, format: {with: VALID_EMAIL_REGEX, message: "is not valid"}, uniqueness: true
	has_secure_password
	validates :password, length: {within: 6..10}, on: :create
	validates :password, length: {within: 6..10}, if: :password, on: :update
	validates :password, format: {with: /(?=.*\d)/, message: "must contain at least 1 digit"}, on: :create
  validates :password, format: {with: /(?=.*\d)/, message: "must contain at least 1 digit"}, if: :password, on: :update;
	has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
	apply_simple_captcha
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  private
  def confirmation_token
      if self.confirm_token.blank?
          self.confirm_token = SecureRandom.urlsafe_base64.to_s
      end
  end
end

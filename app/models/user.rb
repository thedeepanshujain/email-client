class User < ApplicationRecord
	before_save { self.email = email.downcase }
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
    validates :password, presence: true, length: { minimum: 5 }
    has_secure_password

    def update_login_time
    	self.update_attribute('last_login_time', Time.now.to_s(:db))
    	self.update_attribute('last_activity_time', Time.now.to_s(:db))
    end

    def updateActivityTime
      self.update_attribute('last_activity_time', Time.now.to_s(:db))
    end
end

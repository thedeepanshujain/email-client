class User < ApplicationRecord
	before_save { self.email = email.downcase }
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
    validates :password, presence: true, length: { minimum: 5 }
    has_secure_password
    validates :signature, length: { maximum: 10000 }

    def update_login_time
    	self.update_attribute('last_login_time', Time.now.to_s(:db))
    	self.update_attribute('last_activity_time', Time.now.to_s(:db))
    end

    def updateActivityTime
        self.update_attribute('last_activity_time', Time.now.to_s(:db))
    end

    def assigned(message_id)
        self.pending_messages = add_message_id(self.pending_messages, message_id)
        self.pending_count = self.pending_count.nil? ? 1 : self.pending_count+1;
        self.transferred_messages = add_message_id(self.transferred_messages, message_id)
        self.transferred_count = self.transferred_count.nil? ? 1 : self.transferred_count+1
    end

    def unassigned(message_id)
        self.pending_messages = remove_message_id(self.pending_messages, message_id)
        if self.pending_count.nil?
            raise 'Was not assigned to this user'
        else
            self.pending_count = self.pending_count-1
        end    
        
        self.unassigned_messages = add_message_id(self.unassigned_messages, message_id)
        self.unassigned_count = self.unassigned_count.nil? ? 1 : self.unassigned_count+1
    end

    private def add_message_id(json_string, message_id)
        append_array = Array[message_id]
        append_to = Array.new()
        if !json_string.nil?
            append_to = JSON.parse!(json_string)
        end
        append_to += append_array
        return append_to.to_json
    end

    private def remove_message_id(json_string, message_id)
        unless json_string.nil?
            delete_from = JSON.parse!(json_string)

            raise 'Was not assigned to this user' unless delete_from.include? message_id

            delete_from.delete (message_id)
            return delete_from.empty? ? nil : delete_from.to_json
        end

        return nil

    end
end

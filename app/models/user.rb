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

    def assigned(message_id, assigned_from)
        pending_messages = add_message_id(self.pending_messages, message_id)
        self.update_attribute('pending_messages', pending_messages)
        pending_count = self.pending_count.nil? ? 1 : self.pending_count+1;
        self.update_attribute('pending_count', pending_count)
        if !assigned_from.nil?
            transferred_messages = add_message_id(self.transferred_messages, message_id)
            self.update_attribute('transferred_messages', transferred_messages)

            transferred_count = self.transferred_count.nil? ? 1 : self.transferred_count+1
            self.update_attribute('transferred_count', transferred_count)
        end

        
    end

    def unassigned(message_id)
        pending_messages = remove_message_id(self.pending_messages, message_id)
        self.update_attribute('pending_messages', pending_messages)
        if self.pending_count.nil?
            raise 'Was not assigned to this user'
        else
            pending_count = self.pending_count-1
            self.update_attribute('pending_count', pending_count)
        end    
        
        unassigned_messages = add_message_id(self.unassigned_messages, message_id)
        self.update_attribute('unassigned_messages', unassigned_messages)
        
        unassigned_count = self.unassigned_count.nil? ? 1 : self.unassigned_count+1
        self.update_attribute('unassigned_count', unassigned_count)
    end

    def replied_to(message_id)
        puts 'IN REPLIED TO'
        begin
            pending_messages = remove_message_id(self.pending_messages, message_id)
            pending_count = self.pending_count-1
            self.update_attribute('pending_messages', pending_messages)
            self.update_attribute('pending_count', pending_count)
        rescue Exception =>  e
            unless self.admin
                raise e 
            end
        end
        replied_messages = add_message_id(self.replied_messages, message_id)
        replied_count = self.replied_count.nil? ? 1 : self.replied_count+1
        
        self.update_attribute('replied_messages', replied_messages)
        self.update_attribute('replied_count', replied_count)

    end

    def get_pending_messages
        return JSON.parse(self.pending_messages||'[]')
    end

    def get_replied_messages
        return JSON.parse!(self.replied_messages||'[]')
    end



    private def add_message_id(json_string, message_id)
        append_array = Array[message_id]
        append_to = Array.new()
        if !json_string.nil?
            append_to = JSON.parse!(json_string)
            puts append_to.inspect
        end
        append_to += append_array
        puts 'Add Message ID' + append_to.to_json
        return append_to.to_json
    end

    private def remove_message_id(json_string, message_id)
        unless json_string.nil?
            delete_from = JSON.parse!(json_string)

            raise 'Was not assigned to this user' unless delete_from.include? message_id
            puts delete_from[0].class
            puts message_id.class
            puts 'DELETE FROM : '
            puts delete_from
            delete_from.delete (message_id)
            puts 'DELETED'
            puts delete_from
            return delete_from.empty? ? nil : delete_from.to_json
        end

        return nil
    end
end

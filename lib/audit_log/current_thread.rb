module AuditLog
  
  class CurrentThread
    
    class << self
      def who=(user)
        auditing_data[:who] = user
      end
      
      def who
        auditing_data[:who]
      end
    end
    
    private
    
    def self.auditing_data
      Thread.current[:auditing_log] ||= {}
    end
  
  end
  
end
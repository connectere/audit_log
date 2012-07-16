module AuditLog
  
  module Controller

    def self.included(controller)
      controller.before_filter :user_for_audit_log
    end
  
    def user_for_audit_log
      AuditLog::CurrentThread.who = current_user_for_audit_log
    end
    
    def current_user_for_audit_log
      current_user
    end
    
  end
  
end
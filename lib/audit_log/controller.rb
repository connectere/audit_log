module AuditLog
  
  module Controller

    attr_accessor :audited_model
    
    def current_user_for_audit_log
      current_user
    end
    
  end
  
end
module AuditLog
	class Railtie < Rails::Railtie

		initializer 'audit_log.configure_rails_initialization', after: 'active_record.set_configs' do 
			require "audit_log/controller"
			require "audit_log/mapping"
			require "audit_log/observer"
			require "audit_log/logged_model"			
		end
  end
end
require 'singleton'

module AuditLog
  
  class Mapping
    include Singleton
  
    attr_reader :audit_mappings
    
    def self.prepare(&block)
      AuditLog::Mapping.instance.instance_eval(&block)
    end
    
    def initialize
      @audit_mappings = {}
    end
    
    def audit(model_name, options = {})
      @audit_mappings[model_name] = {
        ignored_fields: options[:ignore] || [],
        nested_audited_models: [],
        controllers: options[:controllers] || [model_name]
      }  
      
      @current = @audit_mappings[model_name]
      self
    end
    
    def join(*nested_audited_models)
      @current[:nested_audited_models] = nested_audited_models
      self
    end
  end
  
end

ActiveSupport.on_load(:action_controller) do
  include AuditLog::Controller
end
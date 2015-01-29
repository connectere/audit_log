class AuditedModelsObserver < ActiveRecord::Observer

  attr_accessor :controller
  
  def self.observed_classes
    AuditLog::Mapping.instance.audit_mappings.keys.collect{|model_as_symbol| model_as_symbol.to_s.camelize.constantize}
  end
  
  
  def before_validation(model)
    set_model_to_audit(model)
  end

  def after_create(model)
    if self.controller && self.controller.audited_model == model
      logged_model = LoggedModel.new(
        who: self.controller.current_user_for_audit_log ? self.controller.current_user_for_audit_log.id : nil,
        what: YAML.dump({id: model.id, event: :create}),
        model_class_name: model.class.name,
        model_id: model.id
      )    
      logged_model.save
    end
  end
  
  
  def before_destroy(model)
    set_model_to_audit(model)
    
    if self.controller && self.controller.audited_model == model
      what = {id: model.id, event: :destroy}
      what = what.merge(ActiveSupport::JSON.decode(model.to_json(root: false, include: association_audit_loggers(model))))
      
      logged_model = LoggedModel.new(
        who: self.controller.current_user_for_audit_log ? self.controller.current_user_for_audit_log.id : nil,
        what: YAML.dump(what),
        model_class_name: model.class.name,
        model_id: model.id
      )    
      logged_model.save
      
      self.controller.audited_model = nil
    end
  end
  
  def after_update(model)
    if self.controller && self.controller.audited_model == model
      changes = Thread.current[:audited_model_changes]
      
      if changes
        what = WhatBuilder.new(changes).build
        
        logged_model = LoggedModel.new(
          who: self.controller.current_user_for_audit_log ? self.controller.current_user_for_audit_log.id : nil,
          what: YAML.dump(what),
          model_class_name: model.class.name,
          model_id: model.id
        )    
        logged_model.save
      end
      
      self.controller.audited_model = nil
    end
  end
  
  def before_update(model)
    if self.controller && self.controller.audited_model == model
      if (model.changed? && !(model.changed_attributes.keys.collect{|attr| attr.to_sym}.uniq.sort - ignored_fields(model).uniq.sort).empty?) || 
          has_some_association_changed?(model)
        changes = {model: model, fields_updates: {}, has_many: {}, has_one: {}}
        
        # build main model changes
        model.changed_attributes.
          select{|attribute| attribute != "updated_at" && !ignored_fields(model).include?(attribute.to_sym)}.
          each{|attribute, old_value|
          changes[:fields_updates][attribute.to_sym] = {from: old_value, to: model.send(attribute.to_sym)}
        }  
        
        # build has_many model creations
        association_audit_loggers(model).select{|association| model.send(association).kind_of?(ActiveRecord::Associations::CollectionProxy)}.each{|method_name| 
          changes[:has_many][method_name.to_sym] ||= []
          
          model.send(method_name).select{|a| a.new_record?}.each{|nested|
            changes[:has_many][method_name.to_sym] << {model: nested, event: :create}
          }
        }
        
        # build has_many model updates
        association_audit_loggers(model).select{|association| model.send(association).kind_of?(ActiveRecord::Associations::CollectionProxy)}.each{|method_name| 
          changes[:has_many][method_name.to_sym] ||= []
          
          model.send(method_name).select{|a| a.changed? && !a.new_record?}.each{|nested|
            nested_changes = {model: nested, fields_updates: {}, event: :update}
            changes[:has_many][method_name.to_sym] << nested_changes
            
            nested.changed_attributes.
              select{|attribute| attribute != "updated_at"}.
              each{|attribute, old_value|
              nested_changes[:fields_updates][attribute.to_sym] = {from: old_value, to: nested.send(attribute.to_sym)}
            }  
          }
        }
        
        # build has_many model deletions
        association_audit_loggers(model).select{|association| model.send(association).kind_of?(ActiveRecord::Associations::CollectionProxy)}.each{|method_name| 
          changes[:has_many][method_name.to_sym] ||= []
          
          model.send(method_name).select{|a| a.marked_for_destruction?}.each{|nested|
            changes[:has_many][method_name.to_sym] << {model: nested, event: :destroy}
          }
        }

        
        # build has_one model creations
        association_audit_loggers(model).select{|association| !model.send(association).kind_of?(ActiveRecord::Associations::CollectionProxy) && !model.send(association).nil?}.each{|method_name| 
          has_one_model = model.send(method_name)
          
          if has_one_model.new_record?
            changes[:has_one][method_name.to_sym] = {model: has_one_model, event: :create}
          elsif has_one_model.changed?
            has_one_changes = {model: has_one_model, event: :update, fields_updates: {}}
            has_one_model.changed_attributes.
              select{|attribute| attribute != "updated_at"}.
              each{|attribute, old_value|
              has_one_changes[:fields_updates][attribute.to_sym] = {from: old_value, to: has_one_model.send(attribute.to_sym)}
            }  
            
            changes[:has_one][method_name.to_sym] = has_one_changes
          elsif has_one_model.marked_for_destruction?
            changes[:has_one][method_name.to_sym] = {model: has_one_model, event: :destroy}
          end
        }
        
        Thread.current[:audited_model_changes] = changes
      end
    end
  end
  
  private 
  
  def set_model_to_audit(model)
    if self.controller && is_controller_mapped_to_model(model) 
      self.controller.audited_model ||= model 
    end  
  end
  
  def is_controller_mapped_to_model(model)
    controller_name = self.controller.params[:controller].sub("Controller", "").underscore.split("/").last
    mapped_controller_names = AuditLog::Mapping.instance.audit_mappings[model.class.to_s.underscore.to_sym][:controllers]  
    
    mapped_controller_names.collect{|e| e.to_s.singularize}.include?(controller_name.to_s.singularize)
  end
  
  def has_some_association_changed?(model)
    changed = false
        
    association_audit_loggers(model).each{|method_name| 
      association = model.send(method_name)
      changed = true if association_has_changed?(association)
    }
    
    changed
  end
  
  def association_has_changed?(association)
    # has_many
    if association.kind_of?(ActiveRecord::Associations::CollectionProxy)
      !association.select{|logger| logger.changed? && !logger.new_record?}.empty? ||
      !association.select{|logger| logger.new_record?}.empty? || 
      !association.select{|item| item.marked_for_destruction?}.empty?
      
    # has_one
    else
      association && (association.changed? || association.marked_for_destruction?)
    end
  end
  
  def ignored_fields(model)
    AuditLog::Mapping.instance.audit_mappings[model.class.to_s.underscore.to_sym][:ignored_fields] 
  end
  
  def association_audit_loggers(model)
    AuditLog::Mapping.instance.audit_mappings[model.class.to_s.underscore.to_sym][:nested_audited_models]  
  end
  
  class WhatBuilder
    attr_accessor :changes
    
    def initialize(changes)
      self.changes = changes  
    end
    
    def build
      what = {id: changes[:model].id, event: :update}
      changes[:fields_updates].each{|field_name, old_and_new_values| 
        what[field_name] = old_and_new_values
      }
      
      changes[:has_many].each{|association_name, changes_list|
        what[association_name] = [] unless changes_list.empty?
        changes_list.each{|nested_changes| 
          what_nested = {id: nested_changes[:model].id, event: nested_changes[:event]}
          nested_changes[:fields_updates].each{|field_name, old_and_new_values| 
            what_nested[field_name] = old_and_new_values
          } if nested_changes[:fields_updates]
          what[association_name] << what_nested
        }
      }
      
      changes[:has_one].each{|association_name, nested_changes|
        if nested_changes[:model]
          what_nested = {id: nested_changes[:model].id, event: nested_changes[:event]}
          nested_changes[:fields_updates].each{|field_name, old_and_new_values| 
            what_nested[field_name] = old_and_new_values
          } if nested_changes[:fields_updates]
          what[association_name] = what_nested
        end
      }
      
      what
    end
  end
  
end

require 'singleton'

class ControllerInterceptor
  include Singleton
  
  def around(controller)
    controller.audited_model = nil
    AuditedModelsObserver.instance.controller = controller
    yield
    AuditedModelsObserver.instance.controller = nil
    
    true
  end
end



if defined?(ActionController) and defined?(ActionController::Base)
  ActionController::Base.class_eval do
    around_filter ControllerInterceptor.instance
  end
end
class AuditedModel < ActiveRecord::Base
  attr_accessible :description, :ignored_field, :nested_audited_models, :nested_audited_models_attributes,
    :has_one_audited_model, :has_one_audited_model_attributes
    
  has_many :nested_audited_models
  accepts_nested_attributes_for :nested_audited_models, allow_destroy: true
  
  has_one :has_one_audited_model
  accepts_nested_attributes_for :has_one_audited_model, allow_destroy: true
end

require 'spec_helper'

describe AuditLog::Mapping do
  
  it "maps a single audited model" do
    AuditLog::Mapping.prepare do
      audit(:audited_model)
    end
    
    AuditLog::Mapping.instance.audit_mappings[:audited_model].should eq(
      {ignored_fields: [], nested_audited_models: []}
    )
  end
  
  it "maps a single audited model with ignored fields" do
    AuditLog::Mapping.prepare do
      audit(:audited_model, ignore: [:field_to_ignore])
    end
    
    AuditLog::Mapping.instance.audit_mappings[:audited_model].should eq(
      {ignored_fields: [:field_to_ignore], nested_audited_models: []}
    )
  end
  
  it "maps an audited model with nested audited models" do
    AuditLog::Mapping.prepare do
      audit(:audited_model).join(:nested_audited_model, :another_nested)
    end
    
    AuditLog::Mapping.instance.audit_mappings[:audited_model].should eq(
      {ignored_fields: [], nested_audited_models: [:nested_audited_model, :another_nested]}
    )
  end
  
end
ActionDispatch::Reloader.to_prepare do
  AuditLog::Mapping.prepare do
    audit(:audited_model, ignore: [:ignored_field]).join(:nested_audited_models, :has_one_audited_model)  
    audit(:nested_audited_model)
  end
end

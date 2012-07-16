class AddIgnoredAttributeToAuditedModel < ActiveRecord::Migration
  def change
    add_column :audited_models, :ignored_field, :string
    add_column :nested_audited_models, :ignored_field, :string
  end
end

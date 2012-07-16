class AddAuditedModelToNestedAutitedModel < ActiveRecord::Migration
  def change
    add_column :nested_audited_models, :audited_model_id, :integer
  end
end

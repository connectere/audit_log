class CreateHasOneAuditedModels < ActiveRecord::Migration
  def change
    create_table :has_one_audited_models do |t|
      t.string :description
      t.references :audited_model
      
      t.timestamps
    end
  end
end

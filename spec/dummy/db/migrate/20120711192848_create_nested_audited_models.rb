class CreateNestedAuditedModels < ActiveRecord::Migration
  def change
    create_table :nested_audited_models do |t|
      t.string :nested_description

      t.timestamps
    end
  end
end

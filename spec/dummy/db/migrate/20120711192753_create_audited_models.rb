class CreateAuditedModels < ActiveRecord::Migration
  def change
    create_table :audited_models do |t|
      t.string :description

      t.timestamps
    end
  end
end

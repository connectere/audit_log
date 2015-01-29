class AddFieldsToLoggedModel < ActiveRecord::Migration
  def change
    add_column :logged_models, :model_id, :integer
    add_column :logged_models, :model_class_name, :string
  end
end

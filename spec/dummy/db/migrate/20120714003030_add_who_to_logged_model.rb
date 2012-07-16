class AddWhoToLoggedModel < ActiveRecord::Migration
  def change
    add_column :logged_models, :who, :integer
  end
end

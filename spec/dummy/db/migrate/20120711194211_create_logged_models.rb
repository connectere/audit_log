class CreateLoggedModels < ActiveRecord::Migration
  def change
    create_table :logged_models do |t|
      t.text :what

      t.timestamps
    end
  end
end

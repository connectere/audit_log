class CreateLoggedModels < ActiveRecord::Migration
  
  def change
    create_table :logged_models do |t|
      t.integer :who
      t.text :what
      t.integer :model_id
      t.string :model_class_name
      
      t.timestamps
    end
  end
  
end
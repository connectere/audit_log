class LoggedModel < ActiveRecord::Base
  attr_accessible :who, :what, :model_id, :model_name
  
  def when
    created_at
  end
  
end

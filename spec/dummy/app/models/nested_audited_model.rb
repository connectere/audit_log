class NestedAuditedModel < ActiveRecord::Base
  attr_accessible :nested_description, :ignored_field
end

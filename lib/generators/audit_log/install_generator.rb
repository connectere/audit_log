require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record/migration'

module AuditLog
  
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    extend ActiveRecord::Generators::Migration
    
    source_root File.expand_path('../templates', __FILE__)
    
    desc 'Generates (but does not run) a migration to add a versions table.'

    def create_migration_file
      migration_template 'create_logged_models.rb', 'db/migrate/create_logged_models.rb'
    end
    
  end
  
end
namespace :db do
  def structure(prefix = "")
    File.join(RAILS_ROOT, 'db', "#{prefix}structure.sql")
  end

  def domain
    File.join(RAILS_ROOT, 'db', "domain.sql")
  end
  
  namespace :structure do
    desc "Load the structure.sql file into the test database"
    task :load => [:environment] do
      if File.exists?(structure)
        File.open(structure) do |f|
          $stderr.write "** Loading structure from #{structure}\n"
          ActiveRecord::Base.connection.execute(f.read)
        end
      else
        $stderr.write "** Structure file does not exist: #{structure}\n"
      end
    end
    
    task :dump do
      FileUtils.cp structure("#{RAILS_ENV.downcase}_"), structure
    end
  end

  namespace :domain do
    desc "Load the domain.sql file into the current database"
    task :load => [:environment] do
      if File.exists?(domain)
        File.open(domain) do |f|
          $stderr.write "** Loading domain data from #{domain}\n"
          ActiveRecord::Base.connection.execute(f.read)
        end
      else
        $stderr.write "** Domain file does not exist: #{domain}\n"
      end
    end

    desc "Dump the domain data to domain.sql"
    task :dump do
      conf = Rails::Configuration.new.database_configuration[RAILS_ENV]
      raise "Don't know how to handle anything but postgres" unless conf["adapter"] == "postgresql"
      $stderr.write "** Dumping domain data to #{domain}\n"
      $stderr.write "**   If your database has a password, you will have to enter it here\n"
      opts = []
      opts << "--data-only"
      opts << "--column-inserts"
      opts << "--exclude-table=schema_migrations"
      opts << "-U #{conf["username"]}" if conf["username"]
      opts = opts.join(" ")
      `pg_dump #{opts} #{conf["database"]} > #{domain}`
    end
  end
end

namespace :db do
  if File.exists?(structure)
    # fully override db:reset
    Rake.application.send(:eval, "@tasks.delete('db:reset')")
    desc "Reset the database from the rails structure file corresponding to the environment"
    task :reset => ['db:drop', 'db:create', 'db:structure:load', 'db:domain:load']
  end
  
  desc "Dump the structure after a migration"
  task :migrate do
    Rake::Task["db:structure:dump"].invoke if ActiveRecord::Base.schema_format == :sql
    if RAILS_ENV == "test"
      Rake::Task["db:domain:dump"].invoke if ActiveRecord::Base.schema_format == :sql
    end
  end
end

# The standard test methods wipe the database, which breaks our domain data structure
# so delete all the standard test methods
["functionals", "units", "integration", "all"].each do |tt|
  Rake.application.send(:eval, "@tasks.delete('test:#{tt}')")
end

namespace :test do
  task :all => 'multitest'
  task :units => 'multitest:units'
  task :functionals => 'multitest:functionals'
  task :integration => 'multitest:integration'
end


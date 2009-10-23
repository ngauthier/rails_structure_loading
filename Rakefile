require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rails_structure_loading"
    gem.summary = %Q{Generate and load SQL structure files for your migrations}
    gem.description = %Q{Generate and load SQL structure files for your migrations}
    gem.email = "nick@smartlogicsolutions.com"
    gem.homepage = "http://github.com/ngauthier/rails_structure_loading"
    gem.authors = ["Nick Gauthier"]
    gem.files = FileList["[A-Z]*.*", "{bin,lib,test}/**/*"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end


task :default => :build


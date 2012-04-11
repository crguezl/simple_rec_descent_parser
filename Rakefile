require 'rake/testtask'

# rake test TEST=just_one_file.rb     # run just one test file.
# rake test TESTOPTS="-v"             # run in verbose mode
Rake::TestTask.new do |t|
  # t.libs: List of directories to be added to $LOAD_PATH. (default is ‘lib’)
  t.libs << "test" 
  t.pattern = 'test/tc*.rb' # or t.test_files = FileList['test/tc*.rb'] 
  t.warning = true
  t.verbose = true # verbose test output. (default is false)
end


require 'rake/clean'
CLEANLIST = [ ]
CLEAN.include(CLEANLIST)

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
$bulk_loading=true
print "Clearing database\n"
[Permission, Rule, Grammar, User].each{|table|
    print " clearing " + table.table_name.to_s + "\n"
    table.destroy_all }
print "Populating...\n"

u=User.create(:name => "yourname",
              :passwd => "yourpassword",
	  		  :passwd2=> "yourpassword",
			  :email => "youremail@domain.com>",
			  :reg_hash => "doesntmattercouldbehash")
Permission.create(:user_id => u.id, :admin => 1, :active => 1)

g1=Grammar.create(:name => "Example1", :user_id => u.id, :version => 1, :version_type => 1,
	:desc => "First example from the help page.", :public => 1)
g2=Grammar.create(:name => "Example2", :user_id => u.id, :version => 1, :version_type => 1,
	:desc => "Second example from the help page", :public => 1)
g3=Grammar.create(:name => "Example3", :user_id => u.id, :version => 1, :version_type => 1,
	:desc => "Third example from the help page.", :public => 1)
lz=Grammar.create(:name => "Lazy find_first", :user_id => u.id, :version => 1, :version_type => 1,
	:desc => "Last rules for replacing deprecated find_all and find_first functions in Ruby on Rails",
	:public => 0)

Rule.create(:grammar_id => g1.id,
    :pattern => '/a/, "S2", /a/',
    :translation => '',
    :name => 'S1',
    :priority => '')
Rule.create(:grammar_id => g1.id,
    :pattern => '/b/',
    :translation => '',
    :name => 'S2',
    :priority => '')
Rule.create(:grammar_id => g1.id,
    :pattern => '"S1"',
    :translation => '',
    :name => 'S2',
    :priority => '')

Rule.create(:grammar_id => g2.id,
    :pattern => '/ab/, "S2", [/,/]',
    :translation => '',
    :name => 'S1',
    :priority => '')
Rule.create(:grammar_id => g2.id,
    :pattern => '/b/, "S2"',
    :translation => '',
    :name => 'S2',
    :priority => '')
Rule.create(:grammar_id => g2.id,
    :pattern => '/b/',
    :translation => '',
    :name => 'S2',
    :priority => '')

Rule.create(:grammar_id => g3.id,
    :pattern => '/a/, "S2", /a/',
    :translation => '1, 3, 2',
    :name => 'S1',
    :priority => '')
Rule.create(:grammar_id => g3.id,
    :pattern => '/b/',
    :translation => '',
    :name => 'S2',
    :priority => '')
Rule.create(:grammar_id => g3.id,
    :pattern => '"S1"',
    :translation => '',
    :name => 'S2',
    :priority => '')
	
Rule.create(:grammar_id => lz.id,
    :pattern => '"pre old func", "old func paren params"',
    :translation => '',
    :name => 'old line',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '"pre old func", "old func params"',
    :translation => '',
    :name => 'old line',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '"pre old func", "old func no params"',
    :translation => '',
    :name => 'old line',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '"old func", /\s*\(\s*/, "func array", /\s*\)/, "other"',
    :translation => '1, ", :conditions => [\'", 3, "])", 5',
    :name => 'old func paren params',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '"old func", /\s*\(/, /\s*/, /\)/, "other"',
    :translation => '1, ", :conditions => [\'", 3, "])", 5',
    :name => 'old func paren params',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '"old func", "func array"',
    :translation => '1, ", :conditions => [\'", 2, "])"',
    :name => 'old func params',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '"old func", "other"',
    :translation => '1, ")", 2',
    :name => 'old func no params',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '/\s*.*?\s*\.\s*/',
    :translation => '',
    :name => '"pre old func"',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '/find_first/',
    :translation => '"find(:first"',
    :name => 'old func',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '/find_all/',
    :translation => '"find(:all"',
    :name => 'old func',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '"param key", /\=>/, "param val", [/,/]',
    :translation => '1, " = ?", [:b, " and ", 1, " = ?"], "\'", [", ", 3]',
    :name => 'func array',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '/\s*/, /:/, [0, 9], /\s*/',
    :translation => '3',
    :name => 'param key',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '"old func paren params"',
    :translation => '',
    :name => 'param val',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '"old func no params"',
    :translation => '',
    :name => 'param val',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '/\s*/, []',
    :translation => '2',
    :name => '"param val',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '"pre old func", "old func paren params"',
    :translation => '',
    :name => 'other',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '"pre old func", "old func no params"',
    :translation => '',
    :name => 'other',
    :priority => '')
Rule.create(:grammar_id => lz.id,
    :pattern => '/(\S*\s*)*/',
    :translation => '',
    :name => 'other',
    :priority => '')

	
$bulk_loading=nil
print "Done\n"

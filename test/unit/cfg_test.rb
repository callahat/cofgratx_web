require 'test_helper'

class CFGTest < ActiveSupport::TestCase
  test "initializes" do
    cfg = CFG.new
    assert_equal( {}, cfg.instance_variable_get("@rules") )
    assert_equal( false, cfg.instance_variable_get("@transform") )
  end

  test "clearRule" do
    cfg = CFG.new
    cfg.instance_variable_set( "@rules", {:stuff => [ [[/a/], []] ], :more_stuff => [ [[/b/], [1]] ]} )

    cfg.clearRule("stuff")
    assert_equal( {:more_stuff => [ [[/b/], [1]] ]}, cfg.dumpRules )
  end

  test "clear" do
    cfg = CFG.new
    cfg.instance_variable_set( "@rules", {:stuff => [ [[/a/], []] ], :more_stuff => [ [[/b/], [1]] ]} )

    cfg.clear
    assert_equal( {}, cfg.dumpRules )
  end

  #=====================================================================
  # Rule Validation

  test "validates rules - Non terminal (aka rule name) must be a string" do
    flag = CFG.ruleInvalid 23, [], []
    assert flag
    assert_equal "Nonterminal must be string. You entered a " + 23.class.to_s + "\n", flag

    flag = CFG.ruleInvalid "Valid", [], []
    assert flag.nil?
  end

  test "validates rules - repetition markers" do
    flag = CFG.ruleInvalid "Test", [ [/a/,/b/,","] ], []
    assert flag.nil?, flag

    flag = CFG.ruleInvalid "Test", [ [1, 2, 3] ], []
    assert flag
    assert_match /Repetition marker arrays must consist of one or more String and\/or Regexp/, flag
  end

  test "validates rules - rule arrays" do
    flag = CFG.ruleInvalid "Test", [ /a/ ], []
    assert flag.nil?, flag

    flag = CFG.ruleInvalid "Test", [ "Wall" ], []
    assert flag.nil?, flag

    flag = CFG.ruleInvalid "Test", [ 12 ], []
    assert flag
    assert_match /Rule arrays must be of one or more String and\/or Regexp/, flag
  end

  test "validates rules - translation repitition" do
    flag = CFG.ruleInvalid "Test", [], [ [1, 2, :a] ]
    assert flag.nil?, flag

    flag = CFG.ruleInvalid "Test", [], [ [ 1, /a/ ] ]
    assert flag
    assert_match /Repetition translation arrays must consist of one or more String and\/or Regexp or a symbol :\[a-z\]/, flag
  end

  test "validate rules - translation arrays" do
    flag = CFG.ruleInvalid "Test", [ ], [ 1 ]
    assert flag.nil?, flag

    flag = CFG.ruleInvalid "Test", [ ], [ "asfas" ]
    assert flag.nil?, flag

    flag = CFG.ruleInvalid "Test", [ ], [ /bob/ ]
    assert flag
    assert_match /Translation arrays must be of one or more String and\/or Fixnum \(integer\) and\/or repetition array/, flag
  end

  #=====================================================================
  # addRule

  test "addRule - add an invalid rule" do
    cfg = CFG.new

    cfg.addRule("test", [ 12 ], [])

    assert_equal( {}, cfg.dumpRules )
  end

  test "addRule - add a valid rule" do
    cfg = CFG.new

    rule_criteria1 = [/a/,/b/]
    translation1 = []
    cfg.addRule("Test", rule_criteria1, translation1)

    assert_equal( {:Test => [ [rule_criteria1, translation1] ] }, cfg.dumpRules )

    rule_criteria2 = [/b/]
    translation2 = ["BLANK"]
    cfg.addRule("Test2", rule_criteria2, translation2)

    assert_equal( {:Test => [ [rule_criteria1, translation1] ], :Test2 => [ [rule_criteria2, translation2] ] }, cfg.dumpRules )

    rule_criteria3 = [/a/, "Test2"]
    translation3 = [2, 1]
    cfg.addRule("Test", rule_criteria3, translation3)

    assert_equal( {:Test => [ [rule_criteria1, translation1], [rule_criteria3, translation3] ], :Test2 => [ [rule_criteria2, translation2] ] }, cfg.dumpRules )
  end

  #=====================================================================
  # checkRules
  test "checkRules - rule not defined" do
    cfg = CFG.new
    error, message = cfg.checkRules("test")

    assert_equal true, error
    assert_equal "Initial rule \"test\" not defined in grammar", message
  end

  test "checkRules - not all rules referenced exist" do
    cfg = CFG.new
    cfg.addRule("test", [ "different rule" ], [])
    error, message = cfg.checkRules("test")

    assert_equal true, error
    assert_equal "Not all referenced rules are defined in grammar: different rule", message
  end

  test "checkRules - no errors" do
    cfg = CFG.new
    cfg.addRule("test", [ /test/ ], [])
    error, message = cfg.checkRules("test")

    assert_equal false, error
    assert_equal "No errors with referenced rules", message
  end

  #=====================================================================
  #parseTerminal

  test "parseTerminal - terminal match" do
    cfg = CFG.new
    match = cfg.parseTerminal(/test/, "test and only cut the match", 0)
    assert_equal "test", match

    match = cfg.parseTerminal(/t.*?t the/, "test and only cut the match", 0)
    assert_equal "test and only cut the", match
  end

  test "parseTerminal - terminal does not match" do
    cfg = CFG.new
    match = cfg.parseTerminal(/test/, "NOTHING!", 0)
    assert match.nil?

    match = cfg.parseTerminal(/t.*?t the/, "STILL NOTHING MATCHES", 0)
    assert match.nil?
  end

  #=====================================================================
  #translateHelper
  #todo
end



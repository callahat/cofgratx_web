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

  test "translateHelper - exception on invalid translation object" do
    cfg = CFG.new

    exception = assert_raises(RuntimeError) {
      cfg.translateHelper(/a/, 0, "", [ [/a/, "a"] ], 1, 0)
    }
    assert_equal 'invalid transform element; must be either Fixnum or String or Array, ignoring:Regexp', exception.message
  end

  test "translateHelper - string is the translation object" do
    cfg = CFG.new
    number_of_subrules = 1
    new_translation = cfg.translateHelper("new is appended", 0, "old terms stay ", [ [/new.*/, "new is appended"] ], number_of_subrules, 0)
    assert_equal "old terms stay new is appended", new_translation
  end

  test "translateHelper - fixnum is the tx object, but is larger than number of rules matched" do
    cfg = CFG.new
    number_of_subrules = 2
    new_translation = cfg.translateHelper(3, 0, "nothing returned", [ [/a/, "a"], ["S1", "ab"] ], number_of_subrules, 0)
    assert_equal "", new_translation
  end

  test "translateHelper - fixnum, not within a repeated set of pairs" do
    cfg = CFG.new
    number_of_subrules = 2
    new_translation = cfg.translateHelper(1, 0, "that will be ", [ [/added/, "added"], ["S1", "ab"] ], number_of_subrules, 0)
    assert_equal "that will be added", new_translation
  end

  test "translateHelper - fixnum, within a repeated set of pairs" do
    cfg = CFG.new
    number_of_subrules = 2
    new_translation = cfg.translateHelper(2, 0, "a", [[/[abc]/, "a"], [/,/, ","], [/[abc]/, "b"], [/,/, ","], [/[abc]/, "c"]], number_of_subrules, 0)
    assert_equal "a,", new_translation

    new_translation = cfg.translateHelper(3, 0, "a", [[/[abc]/, "a"], [/,/, ","], [/[abc]/, "b"], [/,/, ","], [/[abc]/, "c"]], number_of_subrules, 0)
    assert_equal "ab", new_translation
  end

  #=====================================================================
  #parseSentance

  test "parseSentance - no rules defined" do
    cfg = CFG.new
    assert_equal nil, cfg.parseSentance("S", "test", 0)
  end

  test "parseSentance - returns nil if no rules match" do
    cfg = CFG.new
    cfg.addRule("Test", [/a/,/b/], [])
    cfg.addRule("Test", [/a/,/c/], [])
    cfg.addRule("Test", [/abcde/], [])
    cfg.instance_variable_set "@rules_checked", 0

    def cfg.parseRule(rule, tx, linecopy, trace); @rules_checked += 1; end

    match, line = cfg.parseSentance("Test", "no match", 0)
    assert match.nil?
    assert line.nil?
    assert_equal 3, cfg.instance_variable_get( "@rules_checked" )
  end

  test "parseSentance - goes through all the rules until a matching rule is found" do
    cfg = CFG.new
    cfg.addRule("Test", [/a/,/b/], [])

    def cfg.parseRule(rule, tx, linecopy, trace); ["ab", "ab rest of sentance"]; end

    match, line = cfg.parseSentance("Test", "ab rest of sentance", 0)
    assert_equal "ab", match
    assert_equal "ab rest of sentance", line
  end

end

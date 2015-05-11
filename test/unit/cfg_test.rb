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
    refute flag

    flag = CFG.ruleInvalid "Test", [ [1, 2, 3] ], []
    assert flag
    assert_match /Repetition marker arrays must consist of one or more String and\/or Regexp/, flag
  end

  test "validates rules - rule arrays" do
    flag = CFG.ruleInvalid "Test", [ /a/ ], []
    refute flag

    flag = CFG.ruleInvalid "Test", [ "Wall" ], []
    refute flag

    flag = CFG.ruleInvalid "Test", [ 12 ], []
    assert flag
    assert_match /Rule arrays must be of one or more String and\/or Regexp/, flag
  end

  test "validates rules - translation repitition" do
    flag = CFG.ruleInvalid "Test", [], [ [1, 2, :a] ]
    refute flag

    flag = CFG.ruleInvalid "Test", [], [ [ 1, /a/ ] ]
    assert flag
    assert_match /Repetition translation arrays must consist of one or more String and\/or Regexp or a symbol :\[a-z\]/, flag
  end

  test "validate rules - translation arrays" do
    flag = CFG.ruleInvalid "Test", [ ], [ 1 ]
    refute flag

    flag = CFG.ruleInvalid "Test", [ ], [ "asfas" ]
    refute flag

    flag = CFG.ruleInvalid "Test", [ ], [ /bob/ ]
    assert flag
    assert_match /Translation arrays must be of one or more String and\/or Fixnum \(integer\) and\/or repetition array/, flag
  end

  #=====================================================================
  # addRule

  test "addRule - add an invalid rule" do
    cfg = CFG.new

    invalid_resp = cfg.addRule("test", [ 12 ], [])

    assert_equal "Rule invalid:\nRule arrays must be of one or more String and/or Regexp\n", invalid_resp
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
    assert_equal [], cfg.parseSentance("S", "test", 0)
  end

  test "parseSentance - returns nil if no rules match" do
    cfg = CFG.new
    cfg.addRule("Test", [/a/,/b/], [])
    cfg.addRule("Test", [/a/,/c/], [])
    cfg.addRule("Test", [/abcde/], [])
    cfg.instance_variable_set "@rules_checked", 0

    def cfg.parseRule(rule, tx, linecopy, trace); @rules_checked += 1; [] end

    matches = cfg.parseSentance("Test", "no match", 0)

    assert_equal 0, matches.size
    assert_equal 3, cfg.instance_variable_get( "@rules_checked" )
  end

  test "parseSentance - goes through all the rules until a matching rule is found" do
    cfg = CFG.new
    cfg.addRule("Test", [/a/,/b/], [])

    def cfg.parseRule(rule, tx, linecopy, trace); [ ["ab", "ab rest of sentance"] ]; end

    matches = cfg.parseSentance("Test", "ab rest of sentance", 0)
    assert_equal 1, matches.size
    match, line = matches.first
    assert_equal "ab", match
    assert_equal "ab rest of sentance", line
  end

  test "parseSentance - rules referencing themselves - complex example" do
    cfg = CFG.new
    cfg.addRule "test", [ /thing/ ], []
    cfg.addRule "S", [/a/, "S", /a/], []
    cfg.addRule "S", [/a/], []
    cfg.addRule "S", ["S", [/ and /]], []

    #this will cause a stack too deep exception
    assert_raises(SystemStackError) {
      matches = cfg.parseSentance("S", "ab rest of sentance", 0)
    }
    #assert_equal 1, matches.size
    #match, line = matches.first
    #assert_equal "a", match
    #assert_equal "a", line

    #matches = cfg.parseSentance("S", "aa and ababababa", 0)
    #assert_equal 1, matches.size
    #match, line = matches.first
    #assert_equal "aa and ababababa", match
    #assert_equal "aa and ababababa", line

  end


  #=====================================================================
  #parseRule

  test "parseRule - no match" do
    cfg = CFG.new
    matches = cfg.parseRule([/a/,/b/], [], "nothing", 0)
    assert_equal [], matches
  end

  test "parseRule - simple match" do
    cfg = CFG.new
    input_string = "ab"
    matches = cfg.parseRule([/a/,/b/], [], input_string, 0)
    terms, new_terms = matches.first
    assert_equal "ab", terms
    assert_equal "ab", new_terms
    assert_equal "ab", input_string
    assert_equal 1, matches.size
  end

  test "parseRule - simple match with repetition" do
    cfg = CFG.new
    input_string = "ab,ab,ab,ab"
    matches = cfg.parseRule([/a/,/b/, [/,/]], [], input_string, 0)
    terms, new_terms = matches.first
    assert_equal "ab,ab,ab,ab", terms
    assert_equal "ab,ab,ab,ab", new_terms
    assert_equal "ab,ab,ab,ab", input_string
    assert_equal 1, matches.size
  end

  test "parseRule - simple match with excess in input string" do
    cfg = CFG.new
    input_string = "ab something else"
    matches = cfg.parseRule([/a/,/b/], [], input_string, 0)
    terms, new_terms = matches.first
    assert_equal "ab", terms
    assert_equal "ab", new_terms
    assert_equal "ab something else", input_string
    assert_equal 1, matches.size
  end

  test "parseRule - match with another rule" do
    cfg = CFG.new
    cfg.addRule "test", [ /thing/ ], []
    input_string = "a thing"
    matches = cfg.parseRule([/a /, "test"], [], input_string, 0)

    terms, new_terms = matches.first

    assert_equal "a thing", terms
    assert_equal "a thing", new_terms
    assert_equal "a thing", input_string
    assert_equal 1, matches.size
  end

  test "parseRule - simple match with translation and excess in input string" do
    cfg = CFG.new
    cfg.instance_variable_set "@transform", true
    input_string = "ab something else"
    matches = cfg.parseRule([/a/,/b/], [2, " flipped with ", 1], input_string, 0)
    terms, new_terms = matches.first
    assert_equal "ab", terms
    assert_equal "b flipped with a", new_terms
    assert_equal "ab something else", input_string
    assert_equal 1, matches.size
  end

  test "parseRule - simple match with repetition and translation" do
    cfg = CFG.new
    cfg.instance_variable_set "@transform", true
    input_string = "ab,ab,ab,ab ab"
    matches = cfg.parseRule([/a/,/b/, [/,/]], [ 1, [:c, " no a's here ", 2] ], input_string, 0)
    terms, new_terms = matches.first
    assert_equal "ab,ab,ab,ab", terms
    assert_equal "a no a's here b no a's here b", new_terms
    assert_equal "ab,ab,ab,ab ab", input_string
    assert_equal 1, matches.size
  end

  #=====================================================================
  #txString

  test "txString - no match" do
    cfg = CFG.new
    cfg.addRule "test", [ /thing/ ], []

    input_string = "a"

    str, new_str = cfg.txString("test", input_string).first

    assert_equal -1, str
    assert_equal "Failed to match given string:#{input_string}", new_str
    assert_equal "a", input_string

    input_string = "thingz"

    results = cfg.txString("test", input_string)
    str, new_str = results.first

    assert_equal -1, str
    assert_equal "Failed to match given string:#{input_string}", new_str
    assert_equal "thingz", input_string
    assert_equal 1, results.size
  end

  test "txString - match" do
    cfg = CFG.new
    cfg.addRule "test", [ /thing/ ], []

    input_string = "thing"

    results = cfg.txString("test", input_string)
    str, new_str = results.first

    assert_equal "thing", str
    assert_equal "thing", new_str
    assert_equal "thing", input_string
    assert_equal 1, results.size
  end

  test "txString - match with translation" do
    cfg = CFG.new
    cfg.addRule "S1", [ /a/, "S2", /a/ ], [1, 3, 2]
    cfg.addRule "S2", [ /b/ ], []
    cfg.addRule "S2", [ "S1" ], []

    results = cfg.txString("S1", "aba")
    str, new_str = results.first
    assert_equal "aba", str
    assert_equal "aab", new_str
    assert_equal 1, results.size

    results = cfg.txString("S1", "aabaa")
    str, new_str = results.first
    assert_equal "aabaa", str
    assert_equal "aaaab", new_str
    assert_equal 1, results.size

    results = cfg.txString("S1", "b")
    str, new_str = results.first
    assert_equal -1, str
    assert_equal "Failed to match given string:b", new_str
    assert_equal 1, results.size
  end

  test "txString - rule order shouldn't matter part one" do
    cfg = CFG.new
    cfg.addRule "S1", [ /b/, "S2" ], []
    cfg.addRule "S2", [ /b/ ], []
    cfg.addRule "S2", [ /ba/ ], []

    results = cfg.txString("S1", "bba")
    str, new_str = results.first
    assert_equal "bba", str
    assert_equal "bba", new_str
    assert_equal 1, results.size
  end

  test "txString - rule order shouldn't matter part two" do
    cfg = CFG.new
    cfg.addRule "S1", [ /b/, "S2" ], []
    cfg.addRule "S2", [ /ba/ ], []
    cfg.addRule "S2", [ /b/ ], []

    results = cfg.txString("S1", "bba")
    str, new_str = results.first
    assert_equal "bba", str
    assert_equal "bba", new_str
    assert_equal 1, results.size
  end

end

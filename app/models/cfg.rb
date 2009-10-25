#define class CFG
class CFG 
  def initialize()
    @rules = {}
    @transform = false
  end
  
  #addRule - Each Symbol may have more than one decomposition rule. Note that
  #          the rules will be traversed in the order they are entered until
  #          a match is found.
  # s - the nonterminal symbol, String
  # d - the decomposition of the symbol, array of strings (nonterminals)
  #     and regexps (which match to terminal symbols)
  #     and an optional array as the last element which contains a regexp specifying the separation
  #        character for repetitions of the preceding decomposition
  # t - the transformation to perform on this rule. Pass in [] if no transformation
  #     to perform. Elements of the transorm array are as follows
  #        n     -Integer. The nth evaluated part of the decomposition array,
  #               cannot be greater than the number of elements in the decomposition array
  #       "s"    -Arbitrary string s 
  #       array  - containts symbol. "s" and n, where n is the starting offset to the matching elements
  #                of the decomposition array. 
  #                the symbol is one character in length, optional, and denotes which repetition
  #                at which to start. If left out, the first repetition (denoted by ':a') will 
  #                be assumed.
  #          ie. rule: [/a/,/b/,[/,/]]
  #              tx:   ["a", [:b, " foo", 2]]
  #      on sentance:  "ab,ab,ab"
  #      translates to: "a foob foob"
  #                
  def addRule (s, d, t)
    #if s.class != String
    #  print "Nonterminal must be string. You entered a " + s.class.to_s + "\n"
    #  return nil
    #end
    #d.each{|r|
    #  if r.class == Array
    #    r.each{|ra|
    #      if ra.class != Regexp && ra.class != String
    #        print "Repetition marker arrays must consist of one or more String and/or Regexp"
    #        return nil
    #      end
    #    }
    #  elsif r.class != Regexp && r.class != String
    #    print "Rule arrays must be of one or more String and/or Regexp\n"
    #    return nil
    #  end
    #}
    #t.each{|r|
    #  if r.class == Array
    #    r.each{|ra|
    #      if ra.class != Fixnum && ra.class != String && (ra.class != Symbol && r.index(ra) != 0)
    #        print "Repetition translation arrays must consist of one or more String and/or Regexp or a symbol :[a-z]" + ra.class.to_s
    #        return nil
    #      end
    #    }
    #  elsif r.class != Fixnum && r.class != String && r.class != Array
    #    print "Translation arrays must be of one or more String and/or Fixnum (integer) and/or repetition array\n" + t.class.to_s
    #    return nil
    #  end
    #}
	
	invalidMsg = CFG.ruleInvalid(s, d, t)
	unless invalidMsg.nil?
      print "Rule invalid:\n" + invalidMsg
    else
      @rules[s.to_sym] = [] unless @rules[s.to_sym]
      @rules[s.to_sym].push([d,t])
	end
  end
  
  def self.ruleInvalid(s, d, t)
    flag = ""
    if s.class != String
      flag += "Nonterminal must be string. You entered a " + s.class.to_s + "\n"
    end
    d.each{|r|
      if r.class == Array
        r.each{|ra|
          if ra.class != Regexp && ra.class != String
            flag += "Repetition marker arrays must consist of one or more String and/or Regexp"
          end
        }
      elsif r.class != Regexp && r.class != String
        flag += "Rule arrays must be of one or more String and/or Regexp\n"
      end
    }
    t.each{|r|
      if r.class == Array
        r.each{|ra|
          if ra.class != Fixnum && ra.class != String && (ra.class != Symbol && r.index(ra) != 0)
            flag += "Repetition translation arrays must consist of one or more String and/or Regexp or a symbol :[a-z]" + ra.class.to_s
          end
        }
      elsif r.class != Fixnum && r.class != String && r.class != Array
        flag += "Translation arrays must be of one or more String and/or Fixnum (integer) and/or repetition array\n" + t.class.to_s
      end
    }
	return nil if flag == ""
	return flag
  end
  
  def clearRule(s)
    @rules[s.to_sym].clear
    @rules.delete(s.to_sym)
  end

  def clear
    @rules = {}
  end
  
  #pretty print of the rules
  def inspect
    @rules.each{|r|
        r[1].each{|d|
          print r[0].to_s + " => " + d[0].inspect + " TXTO " + d[1].inspect + "\n"
        }
      }
  end
  
  #Kinda a debugging front end, allows lots levels of tracing to be dumped to screen, and option
  #to perform or not perform the translation
  def parseString(s, line, trace, transform)
    @allgobbled = false
    @sp = trace
    @transform = transform
    sent,new_sent = parseSentance(s, line, trace)
    if !sent.nil? && @allgobbled
      print "\n\n\nMATCHED!" + sent.nil?.to_s + "." + line + ".\n"
      print "tx to:" + new_sent.to_s + "\n"
    else
      print "\n\n\nNO match" + "." + sent.to_s + "." + line + ".\n"
    end
  end
  
  #main API wrapper function
  def txString(s, line)
    @allgobbled = false
    @transform = true
    sent,new_sent = parseSentance(s, line, 0)
    if !sent.nil? && @allgobbled
      return sent,new_sent
    else
      return -1,"Failed to match given string:" + line
    end
  end
  
  
  def parseSentance(s, line, trace)
  print s + ":" + @rules[s.to_sym].inspect +  "\n"  unless trace < 1
    @rules[s.to_sym].each{|r|
      rule = r[0]
      tx = r[1]
      print spacing(trace) + "Parsing a sentance ]" + line + "[\n" unless trace < 1
      print spacing(trace) + "trying rule:" + rule.to_s + "\n" unless trace < 1
      linecopy = line.dup
      sent, new_sent = parseRule(rule, tx, linecopy, trace-1)
      if sent.class == String
        print spacing(trace) + "." + sent.to_s + "." + sent.class.to_s + "\n" unless trace < 1
        print spacing(trace) + "." + new_sent.to_s + "." + new_sent.class.to_s + "\n" unless trace < 1
        return sent,new_sent
      end
    } unless @rules[s.to_sym].nil?
    return nil
  end
  
  def parseRule(rule, tx, line, trace)
    print spacing(trace) + "Parsing a rule\'" + rule.to_s + "\' \'" + rule.length.to_s + "\'\n" unless trace < 1
    pairs = []
    terms = ""
    new_terms = ""
    orig_rule = rule.dup
    rule_copy = rule.dup
    rep_count = 1
    
    rule_copy.each{|r|
      rep_elem = nil
      print spacing(trace) + "terminal:" + r.to_s + " line: " + line + "\n"      unless trace < 1
      if r.class == String
        pv, newpv = parseSentance(r, line, trace - 1)
        print spacing(trace) + "oSPV:" + pv.to_s + "\n" unless trace < 1
        print spacing(trace) + "nSPV:" + newpv.to_s + "\n" unless trace < 1
      elsif r.class == Regexp
        pv = newpv = parseTerminal(r, line, trace)
        print spacing(trace) + "TPV:" + pv.to_s + "\n" unless trace < 1
      elsif r.class == Array   #repetition stuff
        rep_elem = r
        r=r[0]
        pv = newpv = parseTerminal(r, line, trace)
        print spacing(trace) + "RPV:" + pv.to_s + "\n" unless trace < 1
      end
       
      if pv
        pairs.push([r, newpv])
        terms += pv.to_s
        new_terms += newpv.to_s
        line.slice!(pv)
        print spacing(trace) + "terms:" + terms.to_s + "\n" unless trace < 1
        @allgobbled = true if line.length == 0
        if rep_elem
          rule_copy.push orig_rule[0..-2]
          rule_copy.flatten!
          rule_copy.push rep_elem
          rep_count += 1
        end
      elsif rep_elem  #if the rep element is not found again, assume all have been found and exit normally
        print spacing(trace) + "no more rep elements\n" unless trace < 1
        break
      else
        print spacing(trace) + "FAILS" unless trace < 1
        print terms.inspect + "\n" unless trace < 1
        terms = -1  #string normal return for this
        pairs = []
        return terms, new_terms
        break
      end
    }
    print spacing(trace) + "AFTER\n"       unless trace < 1
    
    print spacing(trace) + line + "\n"       unless trace < 1

    if @transform && !tx.empty?
      print spacing(trace) + "attempting to translate\n"    unless trace < 1
      print spacing(trace) + "pairs array size:" + pairs.size.to_s + "\n"    unless trace < 1
      print spacing(trace) + pairs.inspect + "\n"    unless trace < 1
      print spacing(trace) + "repetitions:" + rep_count.to_s + "\n"    unless trace < 1
      
      new_terms = ""

      for i in 0..(tx.size-1) do
        print spacing(trace) + "tx elem:" + i.to_s + "\n"    unless trace < 1
        if tx[i].class == Array
          if tx[i][0].class == Symbol
            rep_start = tx[i][0].to_s[0] - "a"[0]
            j_start = 1
          else
            rep_start = 0
            j_start = 0
          end
          for rep in rep_start..(rep_count-1) do
            print spacing(trace) + "rep:" + rep.to_s + "\n"    unless trace < 1
            for j in j_start..(tx[i].size-1) do
              new_terms = translateHelper(tx[i][j], rep, new_terms, pairs, orig_rule.size, trace)
              print spacing(trace) + "aft tx   helper:" + new_terms + "\n"    unless trace < 1
            end
            print spacing(trace) + "aft tx j helper:" + new_terms + "\n"    unless trace < 1
          end
        else 
          new_terms = translateHelper(tx[i], 0, new_terms, pairs, orig_rule.size, trace)
          print spacing(trace) + "aft tx helper:" + new_terms + "\n"    unless trace < 1
        end
      end
    end

    #NOTE: the pairs array is used for making transformations easier.
    print spacing(trace) + pairs.inspect + "\n" unless trace < 1
    print spacing(trace) + terms.inspect + "\n" unless trace < 1
    return terms, new_terms
  end
  
  def translateHelper(tx, rep, new_terms, pairs, offset, trace)
    if tx.class == Fixnum
      if tx+offset*rep > pairs.size
        print "Invalid element number, must not be greater than the number of elements in the " +
              "rule array, translation not performed for this rule. BAD NUM:" + (tx+offset*rep).to_s + " size " + pairs.size.to_s + "\n" unless trace < 1
        new_terms = ""
      else
        new_terms += pairs[tx+offset*rep-1][1].to_s
      end
    elsif tx.class == String
      new_terms += tx
    else #should never get this far
      print "invalid transform element; must be either Fixnum or String or Array, ignoring:" + tx.class.to_s unless trace < 1
    end
    return new_terms
  end
  
  def parseTerminal(t, line, trace)
    print spacing(trace) + "Parsing a terminal\n" unless trace < 1
    print spacing(trace) + "Index:" + line.index(t).to_s + " t:" + t.to_s + " line: "+ line + "\n" unless trace < 1
    if line.index(t) == 0
      return line.slice(t)
    else
      return nil
    end
  end
  
  def spacing(trace)
    " "*(@sp - trace)*2
  end
  
  def dumpRules
    return @rules
  end

  def checkRules(initial)
    return true, "Initial rule \"" + initial + "\" not defined in grammar" if @rules[initial.to_sym].nil?
	defined = []
	used = []
	@rules.keys.each{|k|
	  defined << k.to_s
	  @rules[k].each{|pair|
	    pair[0].each{|p|
	      used << p if p.class == String
		}
      }
	}
	difference = used - defined
    return true, "Not all referenced rules are defined in grammar: " + difference.join(", ") unless difference == []
	return false, "No errors with referenced rules"
  end  
end
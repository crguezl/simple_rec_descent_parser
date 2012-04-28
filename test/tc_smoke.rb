require "test/unit"
require "shoulda"

require_relative "../lib/calc/parser"

class TestCalcParser < Test::Unit::TestCase

  context "translating" do
    input = 'a = ( 2 - 3 ) * 5'
    expected = 'a 2 3 - 5 * ='
    calc = Calc::Parser.new( input )
    postfix =  calc.assignment()
    should "be #{expected} for #{input}" do
      assert_equal expected, postfix
    end
  end

  context "translating" do
    input = 'a =  5 - 3 - 2'
    expected = 'a 5 3 - 2 - ='
    calc = Calc::Parser.new( input )
    postfix =  calc.assignment()
    should "be #{expected} for #{input}" do
      assert_equal expected, postfix
    end
  end

  context "translating" do
    input = 'a = b = 4 + 2'
    expected = 'a b 4 2 + = ='
    calc = Calc::Parser.new( input )
    postfix =  calc.assignment()
    should "be #{expected} for #{input}" do
      assert_equal expected, postfix
    end
  end

  context "exceptions" do
    input = '2'
    calc = Calc::Parser.new( input )
    should "Should raise 'SyntaxError' exception for #{input}" do
      assert_raises(SyntaxError) {
        calc.assignment()
      } 
    end
  end

  context "exceptions" do
    input = '3*/4'
    calc = Calc::Parser.new( input )
    should "Should raise 'SyntaxError' exception for '3*4'" do
      assert_raises(SyntaxError) {
        calc.assignment()
      } 
    end
  end

end

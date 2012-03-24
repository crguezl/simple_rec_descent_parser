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

end

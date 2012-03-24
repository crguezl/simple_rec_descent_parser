require "test/unit"
require "shoulda"

require_relative "../lib/calc/simple"

class TestCalcSimple < Test::Unit::TestCase

  context "signature" do
    s =  {"cat" => "act", "act" => "act", "wombat" => "abmotw" }
    s.each do |w,k|
      should "be #{k} for #{w}" do
        assert_equal k, Anagram::Finder.signature_of(w)
      end
    end
  end

  context "lookup" do
    def setup
      @f = Anagram::Finder.new(%w{ cat wombat })
    end

    should "return anagram" do
      assert_equal %w"cat", @f.lookup("cat")
      assert_equal %w"cat", @f.lookup("act")
      assert_nil @f.lookup("win")
    end
  end
end

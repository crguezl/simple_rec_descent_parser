class Token
  attr_accessor :token, :value

  def initialize(token, value=token)
    @token, @value = token, value
  end

  def to_s
    "(#{token}, #{value})"
  end
end

module Tokens
  OPERATOR   = 0
  NUMBER     = 1
  ID         = 2
  UNEXPECTED = 3
end

class LexicalAnalyzer
  include Tokens
  attr_accessor :input, :lexer

  def initialize(input)
    @input = input

    @regexp = %r{([-+*/()=;])|(\d+)|([a-zA-Z_]\w*)|(\S)}
    @lexer = Fiber.new do
       input.scan(@regexp) do |par|
         t = (0..par.length-1).select { |x| !par[x].nil? }
         t = t.shift
         v = par[t]
         if  t == UNEXPECTED
           warn "Unexpected '#{v}' after '#$`'" 
         else
           Fiber.yield Token.new(t, v)
         end
       end
       Fiber.yield nil
    end
  end
end

if $0 == __FILE__
  lex = LexicalAnalyzer.new(ARGV.shift || 'a = ( 2 + 5 )*3') 
  sc  = lex.lexer
  while t = sc.resume
    puts t
  end
end

module Tokens
  OPERATOR   = 0
  NUMBER     = 1
  ID         = 2
  UNEXPECTED = 3
  EOI        = 4

  NAME = {
    0 => :OPERATOR,   
    1 => :NUMBER,    
    2 => :ID,        
    3 => :UNEXPECTED,
    4 => :EOI,
  }
end

class Token
  include Tokens
  attr_accessor :token, :value

  def initialize(token, value=token)
    @token, @value = token, value
  end

  def to_s
    "(#{NAME[token]}, '#{value}')"
  end
end

class CalcParser
  include Tokens
  attr_accessor :input, :lexer, :current_token

  def initialize(input)
    @input = input

    @regexp = %r{
         ([-+*/()=;])              # OPERATOR 
       | (\d+)                     # NUMBER
       | ([a-zA-Z_]\w*)            # ID 
       |(\S)                       # UNEXPECTED
    }x

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
       Fiber.yield  Token.new(EOI, nil)
    end

    next_token

  end

  def match_val(v)
    if (v == current_token.value)
      next_token
    else
      raise "Syntax error. Expected '#{v}', found '#{current_token}'"
    end
  end

  def next_token
     @current_token = @lexer.resume
  end

  def assignment
    t1 = expression
    val = "#{t1}"
    while (current_token.value == '=') 
      op = current_token.value
      next_token
      t2 = expression
      val += " #{t2} #{op}"
    end
    val
  end

  def expression
    t1 = term
    val = "#{t1}"
    while (current_token.value =~ /^[+-]$/) 
      op = current_token.value
      next_token
      t2 = term
      val += " #{t2} #{op}"
    end
    val
  end

  def term
    f = factor
    val = "#{f}"
    while (current_token.value =~ %r{^[*/]$}) 
      op = current_token.value
      next_token
      t = term
      val += " #{t} #{op}"
    end
    val
  end

  def factor
    lookahead, sem  = current_token.token, current_token.value
    if    lookahead == NUMBER   then
      next_token
      sem
    elsif lookahead == ID       then
      next_token
      sem
    elsif sem == '('            then
      next_token
      e = expression()
      match_val(')')
      e
    else
      raise "Syntax error. Expected NUMBER or ID or '(', found #{current_token}"
    end
  end
end

if $0 == __FILE__
  include Tokens
  #calc = CalcParser.new(ARGV.shift || 'a = ( 2 + 5 )*3') 
  #sc  = calc.lexer
  #while t = sc.resume
  #  puts t
  #end

  input = ARGV.shift || 'a = ( 2 - 3 ) * 5'
  calc = CalcParser.new( input )
  postfix =  calc.assignment()
  raise "Unexpected #{calc.current_token}\n" unless calc.current_token.token == EOI
  puts "The translation of '#{input}' to postfix is: #{postfix}"
end

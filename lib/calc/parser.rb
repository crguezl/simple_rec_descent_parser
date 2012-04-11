# /Users/casiano/Dropbox/src/PL/simple_rec_descent_parser

module Calc
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

  class Parser
    include Tokens
    attr_accessor :input, :lexer, :current_token

    def initialize(input = '')
      @input = input                 

      @regexp = %r{
           ([-+*/()=;])              # OPERATOR 
         | (\d+)                     # NUMBER
         | ([a-zA-Z_]\w*)            # ID 
         |(\S)                       # UNEXPECTED
      }x

      @lexer = Fiber.new do
         input.scan(@regexp) do |par|  # [ nil, nil, 'a', nil ]
           t = (0..par.length-1).select { |x| !par[x].nil? }  # [ 2 ]
           t = t.shift                 # 2
           v = par[t]                  # 'a'
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

    def input=(val)
      @input = val
      next_token if input.length > 0
    end

    def match_val(v)
      if (v == current_token.value)
        next_token
      else
        raise SyntaxError, "Syntax error. Expected '#{v}', found '#{current_token}'"
      end
    end

    def next_token
       @current_token = @lexer.resume
    end

    # Operator '=' is right associative
    def assignment     # assignment --> expression '=' assignment | expression
      val = expression
      if (current_token.value == '=') 
        raise SyntaxError, "Error. Expected left-value, found #{val}" unless  val =~ /^[a-z_A-Z]\w*$/
        next_token
        "#{val} #{assignment} ="
      else
        val
      end
    end

    def expression   # expression --> expresion /^[+-]$/ term | term
      t1 = term
      val = "#{t1}"  # expression --> term ( /^[+-]$/ term ) *
      while (current_token.value =~ /^[+-]$/) 
        op = current_token.value
        next_token
        t2 = term
        val += " #{t2} #{op}"
      end
      val
    end

    def term     # term --> term /^[*/]$/ factor | factor
      f = factor
      val = "#{f}"    # term --> factor (/^[*/]$/ factor) *
      while (current_token.value =~ %r{^[*/]$}) 
        op = current_token.value
        next_token
        t = factor
        val += " #{t} #{op}"
      end
      val
    end

    def factor
      lookahead, sem  = current_token.token, current_token.value
      case lookahead 
        when NUMBER
          next_token
          sem
        when ID
          next_token
          sem
        else
          if sem == '(' then
            next_token
            e = assignment()
            match_val(')')
            e
          else
            raise SyntaxError, "Syntax error. Expected NUMBER or ID or '(', found #{current_token}"
          end
      end
    end
  end

  if $0 == __FILE__
    include Tokens

    input = ARGV.shift || 'a = ( 2 - 3 ) * 5'
    calc = Parser.new( input )
    postfix =  calc.assignment()
    raise SyntaxError, "Unexpected #{calc.current_token}\n" unless calc.current_token.token == EOI
    puts "The translation of '#{input}' to postfix is: #{postfix}"

    input = '3 * 5'
    calc = Parser.new( input )
    postfix =  calc.assignment()
    raise SyntaxError, "Unexpected #{calc.current_token}\n" unless calc.current_token.token == EOI
    puts "The translation of '#{input}' to postfix is: #{postfix}"
  end
end

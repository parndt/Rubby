require 'rltk/lexer'

module Rubby
  class Lexer < RLTK::Lexer
    rule /([a-z][a-zA-Z0-9_]+[=?!]?)/, :default do |e|
      [ :IDENTIFIER, e ]
    end

    rule /([A-Z][a-zA-Z0-9_]+)/, :default do |e|
      [ :CONSTANT, e ]
    end

    rule /(0[1-9][0-9]*)/, :default do |e|
      [ :INTEGER, e.to_i(8) ]
    end
    rule /([1-9][0-9]*)/, :default do |e|
      [ :INTEGER, e.to_i ]
    end
    rule /(0x[0-9a-fA-F]+)/, :default do |e|
      [ :INTEGER, e.to_i(16) ]
    end
    rule /(0b[01]+)/, :default do |e|
      [ :INTEGER, e.to_i(2) ]
    end

    rule /([0-9]+\.[0-9]+)/, :default do |e|
      [ :FLOAT, e.to_f ]
    end

    rule /'/, :default do
      push_state :simple_string
      [ :STRING, '' ]
    end
    rule /(\\'|[^'])*/, :simple_string do |e|
      [ :STRING, e.gsub(/\\'/, "'") ]
    end
    rule /'/, :simple_string do
      pop_state
      [ :STRING, '' ]
    end

    rule /"/, :default do
      push_state :complex_string
      [ :STRING, '' ]
    end
    rule /\#\{/, :complex_string do
      push_state :default
      set_flag :inside_complex_string
      [ :INTERPOLATESTART ]
    end
    rule /\}/, :default, [:inside_complex_string] do
      pop_state
      unset_flag :inside_complex_string
      [ :INTERPOLATEEND ]
    end
    rule /(\\"|[^"(\#{)])*/, :complex_string do |e|
      [ :STRING, e.gsub(/\\"/, '"') ]
    end
    rule /"/, :complex_string do
      pop_state
      [ :STRING, '' ]
    end

    %w[ \+ - \* / % \*\* ].each do |op|
      rule(%r|#{op}|) { |e| [ :ARITHMETICOP, e ] }
    end

    %w[ == != > < >= <= <=> === ].each do |op|
      rule(%r|#{op}|) { |e| [ :COMPARISONOP, e ] }
    end

    %w[ = \+= -= \*= /= %= \*\*= ].each do |op|
      rule(%r|#{op}|) { |e| [ :ASSIGNMENTOP, e ] }
    end

    %w[ \& \| \^ ~ << >> ].each do |op|
      rule(%r|#{op}|) { |e| [ :BITWISEOP, e ] }
    end

    %w[ && \|\| \! ].each do |op|
      rule(%r|#{op}|) { |e| [ :LOGICALOP, e ] }
    end

    %w[ \.\. \.\.\. ].each do |op|
      rule(%r|#{op}|) { |e| [ :RANGEOP, e ] }
    end

    rule(/\./) { [ :DOT, '.' ] }
    rule(/::/) { [ :CONSTINDEXOP, '::' ] }
    rule(/\?\?/) { [ :DEFINEDOP, '??' ] }
    rule(/\[/) { [ :LSQUARE, '[' ] }
    rule(/\]/) { [ :RSQUARE, ']' ] }
    rule(/\(/) { [ :LPAREN, '(' ] }
    rule(/\)/) { [ :RPAREN, ')' ] }
    rule(/\{/) { [ :LCURLY, '{' ] }
    rule(/\}/) { [ :RCURLY, '}' ] }
    rule(/,/) { [ :COMMA, ',' ] }
    rule(/@/) { [ :AT, '@' ] }
    rule(/->/) { [ :PROC, '->' ] }
    rule(/\&>/) { [ :BLOCK, '&>' ] }
    rule(/:/) { [ :COLON, ':' ] }

    rule /#+\s*/, :default do
      push_state :comment
    end
    rule /\n/, :comment do
      pop_state
    end
    rule /.*/, :comment do |e|
      [ :COMMENT, e ]
    end

    rule /\s+/, :default do |e|
      [ :WHITE ]
    end
  end
end

require 'strscan'
$error

def preparser(str)
  flag = false # флаг нахождения внутри string
  parsed = []
  scanner = StringScanner.new(str)
  until scanner.empty?
    if !flag && scanner.scan(/\s+/)
    elsif flag && (match = scanner.scan(/\\[nt"]/))
      parsed << ['bs', match]
    elsif match = scanner.scan(/"/)
      flag = !flag
      parsed << ['br', match]
    elsif flag && (match = scanner.scan(/%[dfcsp]/))
      parsed << ['fs', match]
    elsif flag && (match = scanner.scan(/%%/))
      parsed << ['pc', match]
    elsif !flag && (match = scanner.scan(/,/))
      parsed << [',', match]
    elsif match = scanner.scan(/;(?=\Z)/)
      parsed << [';', match]
    elsif !flag && (match = scanner.scan(/scanf/))
      parsed << ['sc', match]
    elsif !flag && (match = scanner.scan(/printf/))
      parsed << ['pr', match]
    elsif !flag && (match = scanner.scan(/(?:&)?[[:alpha:]](?:[[:alnum:]]|_)*(?=\W)/))
      parsed << ['id', match]
    elsif !flag && (match = scanner.scan(/(?:\-|\+)?[[:digit:]]+(?=\W)/))
      parsed << ['dg', match]
    elsif flag && (match = scanner.scan(/([^\\"%])+/)) # TODO: check it
      parsed << ['tt', match]
    elsif !flag && (match = scanner.scan(/'(?:(\\[nt'\\])|(%%)|([^\\'%nt]))'/))
      parsed << ['ch', match]
    elsif !flag && (match = scanner.scan(/'(?:(\\[^nt'\\])|(%[^%])|([\\'%nt]))'/))
      $error = "Wrong char symbol (#{match})"
      raise
    elsif match = scanner.scan(/\(/)
      parsed << ['(', match]
    elsif match = scanner.scan(/\)/)
      parsed << [')', match]
    else
      $error = 'Unknown sequence of symbols'
      raise
    end
  end

  parsed
end

def tokenizer(str)
  tokens = preparser(str)
  if (tokens[0][0] != 'sc') && (tokens[0][0] != 'pr')
    $error = "Wrong function call, #{tokens[0][1]} is not a declared function name"
    raise
  end
  if tokens[-1][0] != ';'
    $error = 'Missing ; at the end of string'
    raise
  end

  opened = 0
  closed = 0
  tokens.each do |elem|
    opened += 1 if elem[0] == '('
    closed += 1 if elem[0] == ')'
  end
  unless opened == closed
    $error = 'Wrong number of brackets'
    raise
  end

  tokens
end

begin
  # # Ввод С++ строки
  print('Input C++ scanf or printf function: ')
  code = gets.chomp
  toster = 'printf("(!$#)+,-:;<=>?@^_‘{|}~");'
  # tester1 = '  printf ("printf %c", '\n');' correct!
  tester2 = 'printf("; %s%d", &abc, qwerty_123);'
  tester3 = 'scanf(");'
  p tokenizer(code)
rescue StandardError
  puts $error
end

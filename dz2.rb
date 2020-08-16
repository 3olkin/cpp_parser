require 'strscan'
$error

def preparser(str)
  flag = false # флаг нахождения внутри string
  parsed = []
  scanner = StringScanner.new(str)
  until scanner.empty?
    if !flag && scanner.scan(/\s+/) # пропуск незначащих пробелов
    elsif flag && (match = scanner.scan(/\\[nt"\\]/)) # экранированные символы (escape symbols)
      parsed << ['bs', match]
    elsif match = scanner.scan(/"/) # кавычка, задающая строку
      flag = !flag
      parsed << ['br', match]
    elsif flag && (match = scanner.scan(/%([\+\-#0\s])?([[:digit:]]+|\*)?(.([[:digit:]]+|\*))?[dfcsp]/)) # символ формата
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
    elsif !flag && (match = scanner.scan(/(?:\-|\+)?[[:digit:]]+.[[:digit:]]+(?=\W)/))
      parsed << ['fl', match]
    elsif !flag && (match = scanner.scan(/(?:\-|\+)?[[:digit:]]+(?=\W)/))
      parsed << ['dg', match]
    elsif flag && (match = scanner.scan(/([^\\"%])+/))
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
  if tokens[-1][0] != ';'
    $error = 'Missing ; at the end of string'
    raise
  end

  i = 0
  terminals = ['br', 'bs', 'fs', ',', ';', '(', ')', 'pc']
  while i < (tokens.length - 1)
    tokens.insert(i + 1, ['@@', '']) if terminals.include?(tokens[i][0]) && terminals.include?(tokens[i + 1][0])
    i += 1
  end

  tokens
end

def analyzer(tokens)
  p tokens
  puts
  puts
  table, header = if tokens[0][0] == 'pr'
                    [printf_table, printf_header]
                  elsif tokens[0][0] == 'sc'
                    [scanf_table, scanf_header]
                  else
                    $error = "Wrong function call, #{tokens[0][1]} is not a declared function name"
                    raise
                  end
  [].tap do |arr|
    stack = [] # накапливаем индексы начала основ
    i = 1
    row = 0
    while i < tokens.length
      col = header.index(tokens[i][0])
      col = (table[0].length - 1) if col.nil?
      case table[row][col]
      when 0
        break
      when 1
        stack << i - 1
      when 2
        nil
      when 3
        arr << [].tap do |tmp|
          i0 = stack.pop
          (i0..i).each do |j|
            tmp.push(tokens[j][0]) if tokens[j][0] != '@@'
          end
        end
      when 99
        $error = 'known error happened'
        raise
      else
        $error = 'unknown error happened'
        raise
      end

      row = col + 1
      i += 2
    end
  end
end

def printf_table
  [
    [99, 99, 99, 99, 1, 99, 99, 99],
    [3, 1, 2, 2, 99, 3, 99, 99],
    [1, 2, 99, 99, 99, 3, 99, 99],
    [3, 99, 2, 2, 99, 99, 99, 99],
    [3, 99, 2, 2, 99, 99, 99, 99],
    [1, 99, 99, 99, 99, 99, 99, 99],
    [99, 99, 99, 99, 99, 99, 3, 99]
  ]
end

def scanf_table
  [
    [99, 99, 99, 1, 99, 99, 99],
    [3, 3, 2, 99, 3, 99, 99],
    [99, 2, 99, 99, 3, 99, 99],
    [3, 99, 2, 99, 99, 99, 99],
    [1, 99, 99, 99, 99, 99, 99],
    [99, 99, 99, 99, 99, 0, 99]
  ]
end

def printf_header
  ['br', ',', 'bs', 'fs', '(', ')', ';', '??']
end

def scanf_header
  ['br', ',', 'fs', '(', ')', ';', '??']
end

begin
  # Ввод С++ строки
  print('Input C++ scanf or printf function: ')
  code = gets.chomp
  analyzer(tokenizer(code)).each do |el|
    p el
  end
rescue StandardError
  puts $error
end

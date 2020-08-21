begin
  # устанавливаем относительный путь до файла
  current_path = File.dirname(__FILE__)
  file_path = current_path + '/setovik.cpp'

  # считываем код из файла
  if File.exist?(file_path)
    file = File.new(file_path, 'r')
    lines = file.readlines
    file.close
    code = lines.join(' ').delete("\n").downcase.squeeze(' ')
    puts 'Inputed code as one line string:'
    p code
  end
rescue StandardError
  puts message
end

def tokenizer(code)
  require 'strscan'

  [].tap do |tokens|
    scanner = StringScanner.new code
    until scanner.empty?
      if scanner.scan(/\s+/)
      elsif match = scanner.scan(/while(?=\s|\()/)
        tokens << ['wh', match]
      elsif match = scanner.scan(/\(/)
        tokens << ['(', match]
      elsif match = scanner.scan(/\)/)
        tokens << [')', match]
      elsif match = scanner.scan(/{/)
        tokens << ['{', match]
      elsif match = scanner.scan(/}/)
        tokens << ['}', match]
      elsif match = scanner.scan(/;/)
        tokens << [';', match]
      elsif match = scanner.scan(/=/)
        tokens << ['=', match]
      elsif match = scanner.scan(/[[:alpha:]](?:[[:alnum:]]|_)*(?=\W)/)
        tokens << ['id', match]
      elsif match = scanner.scan(/(?:\-|\+)?[[:digit:]]+(?=\W)/)
        tokens << ['cn', match]
      else
        raise 'unknown sequense of symbols'
      end
    end

    situations = [
      ['wh', '('],
      [';', 'wh'],
      [')', 'wh'],
      ['{', 'wh'],
      [')', '{'],
      [')', ';'],
      [';', '}'],
      ['##', '}'],
      ['}', '##']
    ]
    i = 0
    while i < (tokens.length - 1)
      tokens.insert(i + 1, ['##', '']) if tokens[i][0] == '}'
      tokens.insert(i + 1, ['@@', '']) if situations.include?([tokens[i][0], tokens[i + 1][0]])
      i += 1
    end
    tokens.insert(0, ['@@', ''])
    tokens << ['@@', ''] << ['##', ''] if tokens[-1][0] == '}'
  end
end

def analyzer(tokens)
  table = automaton_table
  header = table_header
  raise 'no while call' unless tokens[1][0] == 'wh'

  [].tap do |arr|
    stack = []
    i = 1
    row = 0
    while i < tokens.length
      col = header.index(tokens[i][0])
      col = 0 if col.nil?
      case table[row][col]
      when 1
        stack.push(i - 1)
      when 2
        nil
      when 3
        arr << [].tap do |tmp|
          i0 = stack.pop
          (i0..i).each do |j|
            tmp.push(tokens[j]) if tokens[j][0] != '@@'
          end
        end
      when 4
        raise "error happened in this sequence: #{tokens[i - 3]}#{tokens[i - 2]}#{tokens[i - 1]}#{tokens[i]}"
      else
        raise "unknown error happened. check: #{tokens[i - 3]}#{tokens[i - 2]}#{tokens[i - 1]}#{tokens[i]}"
      end

      row = col
      i += 2
    end
    if stack.length == 1
      arr << [].tap do |tmp|
        i0 = stack.pop
        (i0..(tokens.length - 1)).each do |j|
          tmp.push(tokens[j]) if (tokens[j][0] != '@@') && (tokens[j][0] != '##')
        end
      end
    elsif stack.length > 1
      raise "stack is not empty (#{stack})"
    end
  end
end

def automaton_table
  [
    [4, 1, 4, 4, 4, 4, 4, 4, 4],
    [4, 4, 1, 4, 4, 4, 4, 4, 4],
    [4, 4, 4, 3, 4, 4, 4, 4, 4],
    [4, 1, 4, 4, 4, 3, 1, 4, 4],
    [4, 4, 4, 4, 4, 2, 4, 4, 4],
    [4, 1, 4, 4, 2, 4, 4, 3, 4],
    [4, 1, 4, 4, 2, 4, 4, 3, 4],
    [4, 4, 4, 4, 4, 4, 4, 4, 3],
    [4, 4, 4, 4, 4, 4, 4, 2, 4]
  ]
end

def table_header
  ['??', 'wh', '(', ')', '=', ';', '{', '}', '##']
end

tokens = tokenizer(code)
puts 'List of tokens:'
p tokens
puts 'List of blocks:'
analyzer(tokens).each do |el|
  p el
end

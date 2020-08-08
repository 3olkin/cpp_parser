require 'strscan'
$error
# # Ввод С++ строки
# print('Input C++ scanf or printf function: ')
# code = gets.chomp

def preparser(str)
  # metachars = [] # ! заполнить
  flag = false                                            # флаг нахождения внутри string
  parsed = []
  scanner = StringScanner.new(str)
  until scanner.empty?
    if !flag && scanner.scan(/\s+/)                       # пропускаем незначащие пробелы
    elsif match = scanner.scan(/\\"/)                     # находим `"` внутри string
      parsed << ['in', match]
    elsif match = scanner.scan(/"/)                       # находим `"` = граница string
      flag = !flag
      parsed << ['br', match]
    # ? можно выпилить?
    # elsif flag && (match = scanner.scan(/\s+/))         # обрабатываем значащие пробелы
    #   parsed << ['ws', match]
    elsif flag && (match = scanner.scan(/%[dfcs]/)) # находим символы форматов
      parsed << ['sf', match]
    elsif match = scanner.scan(/%%/)                      # находим символ `%`
      parsed << ['%%', match]
    elsif match = scanner.scan(/\\n/)                     # находим символ `\n`
      parsed << ['sn', match]
    elsif !flag && (match = scanner.scan(/,/)) # ?
      parsed << [',', match]
    elsif !flag && (match = scanner.scan(/;(?=\z)/))
      parsed << [';', match]
    elsif !flag && (match = scanner.scan(/scanf/)) # находим вызов функции scanf
      parsed << ['sc', match]
    elsif !flag && (match = scanner.scan(/printf/)) # находим вызов функции printf
      parsed << ['pr', match]
    elsif !flag && (parsed[0][0] == 'pr') && (match = scanner.scan(/[[:alpha:]](?:[[:alnum:]]|_)*(?=\W)/))
      parsed << ['id', match]
    elsif !flag && (parsed[0][0] == 'sc') && (match = scanner.scan(/(?:&)?[[:alpha:]](?:[[:alnum:]]|_)*(?=\W)/))
      parsed << ['id', match]
    elsif !flag && (match = scanner.scan(/(?:\-|\+)?[[:digit:]]+(?=\W)/))
      parsed << ['dg', match]
    elsif flag && (match = scanner.scan(/([^\\"%])+/)) # TODO: check it
      parsed << ['tt', match]
    elsif !flag && (match = scanner.scan(/'(?:\\)?.'/))
      if (match.length == 4) && !metachars.include?(match)
        $error = "Too lot of symbols for char type (#{match})"
        raise
      end
      parsed << ['ch', match]
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

  tokens
end

toster = 'printf("(!$#)+,-:;<=>?@^_‘{|}~");'
# tester1 = '  printf ("printf %c", '\n');' correct!
tester2 = 'printf("; %s%d", &abc, qwerty_123);'
tester3 = 'scanf("%d",(&i));'
p tokenizer(tester3)

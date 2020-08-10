# устанавливаем относительный путь до файла
current_path = File.dirname(__FILE__)
file_path = current_path + '/setovik.cpp'

# считываем код из файла
if File.exist?(file_path)
  file = File.new(file_path, 'r')
  lines = file.readlines
  file.close
  code = lines.join(' ').delete("\n").downcase.squeeze(' ')
  p code
end

def tokenizer(code)
  require 'strscan'

  tokens = []
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
    end
  end

  tokens
end

p tokenizer(code)

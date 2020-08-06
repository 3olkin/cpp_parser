# # Ввод С++ строки
# print('Input C++ scanf or printf function: ')
# code = gets.chomp

def tokenizer(str)
  require 'strscan'
  parsed = []
  tokens = []
  scanner = StringScanner.new(str)
  puts 'Entered tokenizer'
  until scanner.empty?
    if scanner.scan(/\s+/) # пропуск пробелов
    elsif match = scanner.scan(/"(\p{Any})+"(?=,|\))/)
      parsed << ['st', match]
    elsif match = scanner.scan(/,/)
      parsed << [',', match]
    elsif match = scanner.scan(/;(?=\z)/)
      parsed << [';', match]
    elsif match = scanner.scan(/scanf/)
      parsed << ['sc', match]
    elsif match = scanner.scan(/printf/)
      parsed << ['pr', match]
    elsif match = scanner.scan(/[[:alpha:]](?:[[:alnum:]]|_)*(?=\W)/)
      parsed << ['id', match]
    elsif match = scanner.scan(/(?:\-|\+)?[[:digit:]]+(?=\W)/)
      parsed << ['dg', match]
    elsif match = scanner.scan(/\(/)
      parsed << ['(', match]
    elsif match = scanner.scan(/\)/)
      parsed << [')', match]
    else
      parsed << %w[un unknown]
      break
    end
  end
  puts 'Left cycle'
  parsed
end

toster = 'printf ("Hi %с %d %s\n", 15, 10, 20);'

p tokenizer(toster)

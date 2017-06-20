require 'colorize'

puts "loading into memory"
file = File.new('alice.txt')
contents = file.read
search = 'as she spoke'
result = contents.index(search)
if result
  puts contents[result - 20...result] +
       search.colorize(:yellow) +
       contents[result + search.length..result + search.length + 20]
end
file.close()

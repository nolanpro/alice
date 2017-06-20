require 'set'
require 'objspace'
require 'colorize'

STOPWORDS = Set.new %w(the a an for an nor but or yet so in s and it she he to of i you was that as her with at t on this had be)

def clean(line)
  line.gsub!(/\P{ASCII}/, '')
  line.downcase!
  line
end

# whole file in memory
def build_index
  index = {}
  File.('alice.txt').each.with_index do |line, idx|
    clean(line).scan(/\w+/).each do |word|
      next if STOPWORDS.include?(word)
      (index[word] ||= []) << idx
    end
    string_length += line.length
  end
  index
end

# read big file line by line, saving memory
def build_incremental_index
  index = {}
  File.open('alice.txt') do |file| # auto close file
    line_pos = 0
    file.each_line do |line|
      clean(line).scan(/\w+/).each do |word|
        next if STOPWORDS.include?(word)
        (index[word] ||= []) << line_pos
      end
      line_pos = file.pos
    end
  end
  index
end

puts "Indexing"
index = build_incremental_index
results = nil

puts "5 most used words:"
puts index.map { |k, v| [k, v.count] }.sort_by { |a| -a[1] }.to_h.first(5).inspect

puts "Enter word:"
while results.nil?
  search = gets.chomp.downcase
  results = index[search]
  puts 'Not found'.colorize(:red) if results.nil?
end

puts "Found #{results.count} times:"
File.open('alice.txt') do |f|
  results.each do |position|
    f.seek(position, :SET)
    result = f.gets("\n")
    result.gsub!(/(#{search})/i, '\1'.colorize(:yellow))
    puts result.chomp
  end
end

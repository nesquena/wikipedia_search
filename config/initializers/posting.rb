require 'rufus/tokyo'

puts "\nConstructing hash"
url_hash = Hash.new
counter = 0
old_percent = 0
RECORD_NUMBER = 10

input = "#{Rails.root}/public/urls_#{RECORD_NUMBER}"
size = Dir.glob("#{input}/*").size
Dir.glob("#{input}/split_*").each do |file|
  counter += 1
  file_name = File.basename(file)
  new_percent = (counter.to_f/size*100).round
  puts "Opening #{counter}/#{size}: #{file_name}, #{new_percent}% complete" if (new_percent != old_percent and old_percent = new_percent) and new_percent%5 == 0
  File.open(file).each do |line|
    parts = line.split(/\t/)
    url_hash[parts[1].to_i] = parts[0]
  end
end
URL_MAPPING = url_hash
TOTAL_DOCUMENTS = url_hash.keys.size
puts "Size of URL Mapping: #{(Memory::Analyzer.analyze(url_hash).bytes.to_f/(1024*1024)).round} megabytes"

OUTPUT_FILES_PATH = "#{Rails.root}/public/posting_list_#{RECORD_NUMBER}"
cabinet_path = "#{Rails.root}/public/posting_#{RECORD_NUMBER}.tct"
TERMS_HASH = Rufus::Tokyo::Table.new(cabinet_path)
#puts "Size of lookup hash in memory: #{(Memory::Analyzer.analyze(TERMS_HASH).bytes.to_f/(1024*1024)).round} megabytes"
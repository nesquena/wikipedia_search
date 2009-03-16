require 'rubygems'
require 'rufus/tokyo'
require 'activesupport'

NUM_FILES = 500000

db = Rufus::Tokyo::Table.new("posting_#{NUM_FILES}.tct")


counter = 0
size = Dir.glob("posting_list_#{NUM_FILES}/part-*").size
Dir.glob("posting_list_#{NUM_FILES}/part-*").each do |file|
  start_time = Time.now
  puts "[#{(counter.to_f/size.to_f*100).round}%] opening file: #{file}, #{counter}/#{size}"
  counter += 1
  File.open(file).each do |line|
    line=~/^(.*?)\s?,\s?(\d*)\s?,\s?(\d*)\s?\:\t(.*)/
    word, tf, df, doc_hash = $1, $2, $3, $4
      doc_hash = doc_hash.gsub(/\=/, '=>')
      db[word] = {'df' => df.to_s, 'doc_hash' => doc_hash, 'tf' => tf.to_s}
  end
  end_time = Time.now
  puts "Took #{(end_time - start_time)/60} minutes to process #{file}"
end
db.close
puts "#{(counter.to_f/size.to_f*100).round}% complete"
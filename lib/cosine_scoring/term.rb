module CosineScoring
  class Term
    
    def self.from_source(word, use_cloud)
      return from_file(word) unless use_cloud
      # from_db(word)
      Rails.cache.fetch("#{word}_term") { from_db(word) }
    end
    
    def self.from_db(word)
      Profile.measure('fetch => tokyo') { @record = TERMS_HASH[word] }
      Rails.logger.info @record['tf']
      if @record and @record['tf'].to_i < (RECORD_NUMBER / 10)
        Profile.measure('fetch => yaml') { @doc_hash = eval(@record['doc_hash']) }
        @df = @record['df'].to_i
      else
        @df, @doc_hash = 0, {}
      end
      Term.new(word, @df, @doc_hash)
    end

    def self.from_file(word)
      file_name = word[0]%26
      file_name = "0#{file_name}" if file_name < 10
      puts "\nFinding: #{word} in file #{OUTPUT_FILES_PATH}/part-000#{file_name}"
      File.open("#{OUTPUT_FILES_PATH}/part-000#{file_name}").each do |line|
        term_string = from_string(line, word)
        return term_string unless term_string.nil?
      end
      return Term.new(word, 0, {}) #it doesn't find it
    end

    def self.from_string(line, word)
      if(line=~/^#{word}\s?,\s?(\d*)\s?,\s?(\d*)\s?\:\t(.*)/)
        tf, df, doc_hash = $1, $2, $3
        doc_values = doc_hash.gsub(/\=/, '=>')
        return Term.new(word, df.to_i, eval(doc_values))
      end
      return nil
    end

    #term_count_hash:
    #{ docid => term_count}
    # {1=>5, 2=>2, 3=> 3}
    attr_accessor :word
    def initialize(word, document_frequency, term_count_hash)
      @word, @document_frequency, @term_count_hash = word, document_frequency, term_count_hash
    end

    def docids
      @term_count_hash.keys
    end
    
    def count_in_all_documents
      @term_count_hash.values.sum
    end

    def count_in_document(docid)
      @term_count_hash[docid].to_f || 0.0
    end

    #ln(total_docs / document_frequency)
    def idf
     # Rails.logger.info("#{@word}: #{@document_frequency}")
      if @document_frequency.zero?
       # Rails.logger.info("found 0 idf")
        return 0 
      end
      Math.log(TOTAL_DOCUMENTS/@document_frequency.to_f)
    end
  end
end

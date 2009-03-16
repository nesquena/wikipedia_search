module QueryHandler
  class DocumentFragment
    
    # create a document to compare against a query
    def self.construct(docid, terms, query_doc)
      d1 = DocumentFragment.new(docid, terms)
      d1.score_value = d1.calculate_similarity(query_doc)
      return d1
    end
    
    # assumption each word is unique
    def self.from_query(query_string)
      keywords = query_string.downcase.squeeze(" ").split(/\s/)
      keywords = keywords.collect{ |k| Term.new(k, 1, {"q" => 1})}
      DocumentFragment.new("q", keywords)
    end

    attr_reader :docid
    attr_accessor :score_value

    # term_list is an array of terms objects.
    def initialize(docid, terms_list)
      @docid, @term_hash = docid, to_term_hash(terms_list)
    end
    
    # returns an array of terms
    def terms
      @term_hash.values
    end
    
    # returns the list of words contained in this document fragment
    def words
      terms.collect { |t| t.word }
    end
    
    # returns the url for this document fragment
    def url
      URL_MAPPING[@docid]
    end
    
    # returns a result based on this document
    def to_result
      Result.new(url, docid, score_value, term_count_hash)
    end

    # defines comparator for sorting documents
    def <=>(doc2)
      doc2.score_value <=> self.score_value
    end
    
    # calculates similarity score between two document fragments (integer value)
    def calculate_similarity(other_doc)
      self.terms.inject(0.0) do |dot_product, term|
        dot_product + (self.tfidf(term.word) * other_doc.tfidf(term.word))
      end
    end
    
    protected 
    
    # { word => tc, word => tc }
    def term_count_hash
      @term_hash.values.inject({}) { |hash, term| hash[term.word] = term.count_in_document(@docid); hash }
    end
    
    # returns a term hash from the array
    def to_term_hash(term_array)
      term_array.inject({ }) { |result_hash, term| result_hash[term.word] = term; result_hash } 
    end
    
    # returns a term record from a term or a word
    def to_term_record(term_or_word)
      return term_or_word if term_or_word.respond_to?(:word)
      return @term_hash[term_or_word]
    end
    
    # returns tf*idf for a specified term
    def tfidf(term)
      term = to_term_record(term)
      tf(term) * term.idf
    end

    # 1+ln(termcount)
    def tf(term)
      term = to_term_record(term)
      return 0 if (tc = term.count_in_document(@docid)) == 0
      1 + Math.log(tc)
    end

  end
end

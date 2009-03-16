module CosineScoring
  class DocumentFragment
    
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
      @docid, @terms = docid, terms_list
    end

    # hash of tfidfs for each term in document { word => tfidf, word => tfidf }
    def tfidf_hash
      @terms.inject(Hash.new(0)) { |hash, term| hash[term.word] = tfidf(term); hash }
    end

    # { word => tc, word => tc }
    def term_count_hash
      @terms.inject({}) { |hash, term| hash[term.word] = term.count_in_document(@docid); hash }
    end
    
    # returns the list of words contained in this document fragment
    def words
      @terms.collect { |t| t.word }
    end
    
    # returns the url for this document fragment
    def url
      URL_MAPPING[@docid]
    end
    
    # returns a result based on this document
    def to_result
      Result.new(url, docid, score_value, term_count_hash)
    end

    # returns tf*idf for a specified term
    def tfidf(term)
      tf(term) * term.idf
    end

    # 1+ln(termcount)
    def tf(term)
      return 0 if (tc = term.count_in_document(@docid)) == 0
      1 + Math.log(tc)
    end

    # defines comparator for sorting documents
    def <=>(doc2)
      doc2.score_value <=> self.score_value
    end

  end
end

module CosineScoring
  class Result

    attr_reader :title, :docid, :score_value, :term_count_hash

    def initialize(title, docid, score_value, term_count_hash)
      @title, @docid, @score_value, @term_count_hash = title, docid, score_value, term_count_hash
    end
    
    def link
     "http://en.wikipedia.org/wiki/#{title}"
    end

  end
end

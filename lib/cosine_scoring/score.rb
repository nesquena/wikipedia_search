=begin

  step 1, parse query_string into array (separated by space) of term_objects 
  step 2, grab term from posting_list (faked now) and create term_objects
  step 3, grab all docids based on term information @terms.collect(&:doc_ids).flatten.uniq
  step 4, create document classes by iterating through docids and constructing doc objects
  step 5, create score_vectors on all documents
  step 6, go through each document and store the score
  step 7, sort these similarity scores (sorting documents)

=end

module CosineScoring
  class Score
    # Returns result information for a particular query using results from search_documents
    # Returns [Document, Document, Document] up to 10 results
    def self.search_results(query_string, use_cloud)
      documents, fetching_time, scoring_time, sort_time = search_documents(query_string, use_cloud)
      results = documents[0...10].collect { |document| document.to_result }
      return results, documents.size, fetching_time, scoring_time, sort_time
    end

    protected

    # Performs a search based on a query, sorting documents by cosine score
    # Returns [Document, Document, Document]
    def self.search_documents(query_string, use_cloud)
      query_doc = DocumentFragment.from_query(query_string) # step 1
      fetching_time = Profile.measure(:fetch) { @terms = posting_terms_for(query_doc, use_cloud) } # step 2
      score_time    = Profile.measure(:score) { @documents_array = collect_documents(@terms, query_doc.tfidf_hash) } # step 3 and 4
      sort_time     = Profile.measure(:sort)  { @documents_array.sort! } # step 5, 6, and 7
      return @documents_array, fetching_time, score_time, sort_time
    end

    private

    # returning the terms needed for the query from the specified source
    # [ Term, Term, Term ]
    def self.posting_terms_for(query_document, use_cloud)
      query_document.words.collect { |word| Term.from_source(word, use_cloud) }
    end

    # returns the document fragments for every document which contains a term from the query
    # removes duplicate docids which exist in multiple terms
    # return { docid => Document, docid => Document }
    def self.collect_documents(terms, query_vector)
      @document_hash, @query_vector = Hash.new, query_vector
      @terms.each { |term| construct_documents_for(term) }
      @document_hash.values
    end

    # creates document fragments and calculates scores for all documents which contain a term
    # return { docid => Document, docid => Document }
    #
    # NOTE: Slowness occurs starting here!
    # == search with query 'external' ==
    # create doc with entire scoring process              ~ 9.5 seconds
    # create doc w/o invoking score but with d&q scoring  ~ 8.2 seconds
    # create doc w/o d&q scoring but with invoking score  ~ 5.2 seconds
    # create doc w/o invoking score or d&q scoring        ~ 3.6 seconds
    def self.construct_documents_for(term)
      Profile.measure("scoring => #{term.word} (#{term.docids.length} docs)") do
        term.docids.each { |docid| @document_hash[docid] ||= construct_document(docid)  }
      end
    end

    # constructs a document object with a relevance cosing score based on a docid, terms and query vector
    def self.construct_document(docid)
      d1 = DocumentFragment.new(docid, @terms)
      d1.score_value = score(@query_vector, d1.tfidf_hash)
      return d1
    end

    # returns the score of the query_vector (alphas) dot producted with document_vector (betas)
    # (q dotted d) / |d|
    # |d| = d1^2+d2^2)^1/2
    #|d| = sqrt(d dotted d)
    def self.score(query_tfidf_hash, document_tfidf_hash)
      document_magnitude = 0.0
      query_magnitude = 0.0
      dot_product = 0.0
      query_tfidf_hash.each do |word, tfidf|
        # document_magnitude += (document_tfidf_hash[word] * document_tfidf_hash[word])
        # query_magnitude += (query_tfidf_hash[word] * query_tfidf_hash[word])
        dot_product += (query_tfidf_hash[word] * document_tfidf_hash[word])
      end 
      dot_product # / (Math.sqrt(query_magnitude) * Math.sqrt(document_magnitude))
    end
  end
end

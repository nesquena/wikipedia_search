module QueryHandler
  class Manager
    # Returns result information for a particular query using results from search_documents
    # Returns [Document, Document, Document] up to 10 results
    def self.search_results(query_string, use_cloud)
      documents, fetching_time, scoring_time, sort_time = search_documents(query_string, use_cloud)
      results = documents[0...10].collect { |document| document.to_result }
      return results, documents.size, fetching_time, scoring_time, sort_time
    end

    protected

    # Performs a search based on a query, sorting documents by similarity score
    # Returns [Document, Document, Document]
    def self.search_documents(query_string, use_cloud)
      query_doc = DocumentFragment.from_query(query_string) 
      fetching_time = Profile.measure(:fetch) { @terms = posting_terms_for(query_doc, use_cloud) } 
      score_time    = Profile.measure(:score) { @documents_array = collect_documents(@terms, query_doc) } 
      sort_time     = Profile.measure(:sort)  { @documents_array.sort! }
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
    def self.collect_documents(terms, query_doc)
      @document_hash, @query_doc = Hash.new, query_doc
      terms.each { |term| construct_documents_for(term) }
      @document_hash.values
    end

    # creates document fragments and calculates scores for all documents which contain a term
    # return { docid => Document, docid => Document }
    def self.construct_documents_for(term)
      Profile.measure("scoring => #{term.word} (#{term.docids.length} docs)") do
        term.docids.each { |docid| @document_hash[docid] ||= DocumentFragment.construct(docid, @terms, @query_doc)}
      end
    end
  end
end

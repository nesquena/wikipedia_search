WikiSearch
==========

Overview
--------

In my last year of undergraduate study at UCI, I enrolled in a class called Informatics 141 - 
Information Retrieval. I am majoring in Informatics, which is basically an offshoot of computer science 
focuses more on software engineering and human computer interaction studies. This class was taught by
a professor named Don Patterson. 

The final assignment for the class was to create a system for searching wikipedia that used a
postings list and a reverse lookup table of urls. The basic assignment was to create a
Java program which, given a query, would return the best results using a modified version
of the standard ranking algorithm for determining a similarity score. 
More information on the assignment can be found here: 

[Informatics 141 Assignment 7](http://www.ics.uci.edu/~djp3/classes/2009_01_02_INF141/Assignments/Assignment07.html)

For extra credit, students could create a web site which allowed the user to perform queries,
as well as a firefox extension which would automate the process and return relevant links. For this
assignment, my pair programming partner (Thomas) and I decided to implement the entire project
in Ruby and Rails.

The source code for our rails application is hosted here. Check out the following important files:

 * `app/controllers/query_controller.rb`
 * `app/views/query/*`
 * `lib/query_handler/*`
    
Note that the actual 500,000 postings list data has been ommitted making this far from actually useable.
The data source present is a much smaller sampling of data (a postings list for about 10 pages of wikipedia)
A more detailed explanation of items of interest is below.

Details
-------

The Informatics 141 class had several assignments which were intended to teach us how to create a search engine using
a crawler, a posting list, and similarity score ranked retrieval algorithm. 

In previous assignments, we had built an entire postings list for a large portion of Wikipedia (500,000 article).
A postings list, for those who aren't up on the fancy information retrieval lingo is a standardized method of
storing information such that it can be easily searched and used as the data source for a search engine.

### Postings List ###

More specifically, a postings list is most commonly a series of text files which contain information about 
the contents of a corpus (series of documents). For each document, the content (without any html) is extracted and 
turned into a 'bag of words'. This is essentially just an array of all words on the page. Then the words are counted
up and stored in a large hash of key-pair values as such:

    *word*, *term count*, *document frequency* : { *docid* => *document term count* } 
    elephant , 11 , 4 :	{3=6, 4=1, 5=1, 7=3}
    
For example, the line above means the following:

 * The word 'elephant' appeared 6 times over the entire corpus.
 * The word 'elephant' appeared in 4 distinct documents in the corpus. 
 * In document 3, the word 'elephant' appeared 11 times
 * In document 4, the word 'elephant' appeared 1 time
 * In document 5, the word 'elephant' appeared 1 time
 * In document 7, the word 'elephant' appeared 3 times

The term count is a summation of all the document term counts and the document frequency is
a summation of the number of documents. This is intentional so that these calculations do not have
to happen during the retrieval.

You can see an example of an actual posting list for a corpus of 10 wikipedia documents by viewing `public/posting_list_10/part-*`

A postings list can be enormous over a large corpus and the text files that are stored are not generally
very easy to work quickly with for an actual application due to a lengthy retrieval process to find a
particular term. This would be well-suited for a hash but the huge potential size means it cannot be stored
feasibly within memory. 

### Posting List Disk-based Hash ###

For this assignment we converted these posting list files into a large permanent disk-based hash.
The library we used to do this was 'rufus-tokyo' which is a ruby library for Tokyo Cabinet.

Our method for converting the postings list into a tokyo cabinet hash can be found in `public/posting_hash.rb`.
The basic procedure is to iterate through all the files in the postings list and for each line:

    line=~/^(.*?)\s?,\s?(\d*)\s?,\s?(\d*)\s?\:\t(.*)/
    word, tf, df, doc_hash = $1, $2, $3, $4
    doc_hash = doc_hash.gsub(/\=/, '=>')
    db[word] = {'df' => df.to_s, 'doc_hash' => doc_hash, 'tf' => tf.to_s}

This converts a line such as:

    elephant , 11 , 4 :	{3=6, 4=1, 5=1, 7=3}
    
into a record in the disk-based tokyo table:

    db['elephant'] = { 'tf' => 11, 'df' => 4, 'doc_hash' => "{3=>6, 4=>1, 5=>1, 7=>3}" }

Once the postings list has been converted into the tokyo table, fetching information on a term
is simple:

    db = Rufus::Tokyo::Table.new(file_path)
    db['elephant'] # => { 'tf' => 11, 'df' => 4, 'doc_hash' => "{3=>6, 4=>1, 5=>1, 7=>3}" }
    db.close

Using this system, we can easily access the data needed to perform similarity scoring on a query and
return the relevant matching documents.
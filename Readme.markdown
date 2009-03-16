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
of the standard cosine ranking algorithm for determining a similarity score. 
More information on the assignment can be found here: 

`http://www.ics.uci.edu/~djp3/classes/2009_01_02_INF141/Assignments/Assignment07.html`

For extra credit, students could create a web site which allowed the user to perform queries,
as well as a firefox extension which would automate the process and return relevant links. For this
assignment, my pair programming partner (Thomas) and I decided to implement the entire project
in Ruby and Rails.

The source code for our rails application is hosted here. Check out the following important files:

    app/controllers/query_controller.rb
    app/views/query/*
    lib/cosine_score/*
    
A more detailed explanation of items of interest is below.

Details
-------

The Informatics 141 class had several assignments which were intended to teach us how to create a search engine using
a crawler, a posting list, and cosine score ranked retrieval algorithm. 

In previous assignments, we had built an entire postings list for a large portion of Wikipedia (500,000 article).
A postings list, for those who aren't up on the fancy information retrieval lingo is a standardized method of
storing information such that it can be easily searched and used as the data source for a search engine.

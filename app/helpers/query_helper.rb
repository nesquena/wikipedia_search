module QueryHelper

  def place_results(results, query)
    return "There were no results for '#{query}'" if results.empty?
    render :partial => 'result.html.haml', :collection => @results[0..10]
  end
  
  # Work - Wikipedia, the free encyclopedia
  
  def place_wiki_title(result)
    link_to "#{wrap_strong(result.title)} - Wikipedia, the free encyclopedia", result.link
  end
  
  def place_term_counts(result)
    tc_array = result.term_count_hash.sort {|w1, w2| w2.second <=> w1.second}
    tc_array.collect { |word, count| "#{word} (#{count.to_i})" }.join(", ")
  end

  #Results 1 - 10 of about 1,800,000,000 for work [definition]. (0.22 seconds)
  def place_results_statistics(results, count, query, time_to_complete, speedy, fetching_time, scoring_time, sorting_time)
    showing = (count < 10 ? count : 10)
    showing_div = content_tag(:strong, "1 - #{showing}")
    time_frame = (speedy ? "blazing" : "slow")
    html = "Results #{showing_div} of #{wrap_strong(count)} for #{wrap_strong(query)}. "
    html << "(#{wrap_strong(round_time(time_to_complete))} seconds #{time_frame}: "
    html << "#{wrap_strong(round_time(fetching_time))}s to fetch, "
    html << "#{wrap_strong(round_time(scoring_time))}s to score, "
    html << "#{wrap_strong(round_time(sorting_time))}s to sort)"
    html
  end
  
  def round_time(time_in_seconds)
    (time_in_seconds*100).round/100.0
  end
  

  def wrap_strong(phrase)
    content_tag :strong, phrase
  end

end

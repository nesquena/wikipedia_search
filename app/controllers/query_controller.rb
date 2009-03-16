class QueryController < ApplicationController
  def new
    respond_to do |wants|
      wants.html
    end
  end

  def create
    @query, @speedy = params[:query], params[:speedy]
    @time_to_complete = Profile.measure(:overall) do
      @results, @count, @fetching_time, @scoring_time, @sorting_time = QueryHandler::Manager.search_results(@query, @speedy)
    end
    
    respond_to do |wants|
      wants.js
      wants.json {render :json => { :results => @results[0...3].collect(&:title) , :total => @count } }
    end
  end
end

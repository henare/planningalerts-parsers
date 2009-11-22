$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'planning_authority_results'
require 'scraper'

class BlueMountainsScraper < Scraper
  @planning_authority_name = "Blue Mountains City Council"
  @planning_authority_short_name = "Blue Mountains"
  
  class << self
    attr_reader :planning_authority_name, :planning_authority_short_name
  end
  
  def applications(date)
    # TODO: We're currently ignoring the date. Need to figure out what to do here
    
    # This is the page that we're parsing
    url = "http://www.bmcc.nsw.gov.au/files/daily_planning_notifications.htm"

    page = agent.get(url)
    results = PlanningAuthorityResults.new(:name => self.class.planning_authority_name, :short_name => self.class.planning_authority_short_name)
    page.search('table > tr').each do |row|
      values = row.search('td').map {|t| t.inner_text.strip.delete("\n")}
      results << DevelopmentApplication.new(:application_id => values[0], :address => values[1], :description => values[2],
        :on_notice_from => values[3], :on_notice_to => values[4]) unless values.empty?
    end
    results
  end
end


require 'scraper'
require 'cgi'

class HawkesburyScraper < Scraper
  def applications(date)
    url = "http://council.hawkesbury.nsw.gov.au/MasterViewUI/Modules/applicationmaster/default.aspx?page=found&1=#{date.strftime('%d/%m/%Y')}&2=#{date.strftime('%d/%m/%Y')}&3=&4=DA&4a=DA&6=F"
    page = agent.get(url)

    (page/'//*[@id="ctl00_cphContent_ctl01_ctl00_RadGrid1_ctl00"]').search("tbody/tr").map do |app|
      application_id = app.at("td[2]").inner_text.strip
      DevelopmentApplication.new(
        :application_id => application_id,
        :description => app.at("td[4]").inner_html.split('<br>')[1].strip,
        :address => app.at("td[4]").inner_html.split('<br>')[0].strip,
        :info_url => extract_relative_url(app),
        :comment_url => email_url("council@hawkesbury.nsw.gov.au", "Development Application Enquiry: #{application_id}"),
        :date_received => app.at("td[3]").inner_text.strip)
    end
  end
end

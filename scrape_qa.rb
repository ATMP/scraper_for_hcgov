require 'open-uri'
require 'nokogiri'
require 'json'
require 'httparty'

DOMAIN = 'http://1999.hccg.gov.tw/'
URL = 'faq_list.jsp'
# PAGES = (1...3)
PAGES = (1...304)

# first layer scrape 
urls = []
PAGES.each do |num|
  result = HTTParty.post(DOMAIN+URL, 
    :body => { :page => num.to_s, 
               :intpage => (num+1).to_s, 
               :typeno => '', 
               :qorg => '',
               :qunit => '', 
               :keyword => ''
             }
  )
  entrys = Nokogiri::HTML(result).xpath("//*[@name='mform']//a")
  entrys.each do |entry|
  	url = entry.attributes['href'].value
  	urls << url unless url.include? 'javascript'
  end
end


# second layer scrape
output = urls.map do |url|
  result = Nokogiri::HTML(open(DOMAIN+url))
  info = result.xpath("//*[@name='mform']//*[@class='search01']").map {|i| i.text}
  question = result.xpath("//*[@class='c001']")[1].text.strip
  answer = result.xpath("//*[@class='c001']")[2].text.strip
  {info: info, question: question, answer: answer}
end.to_json


File.write('qa.json',output)






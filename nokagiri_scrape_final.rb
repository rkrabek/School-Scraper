require 'capybara/poltergeist'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'pry'

def accessingHTML(page)
	Nokogiri::HTML(open(page))
end

def nokagiriiScrape(array, var, page, css)
	var = page.css(css)
	if var
		array << var.text
	else
		array << "no #{var} provided"
	end
end

def getEmails(browser, emails_array, index)
	email_links = browser.all('tbody tr td span a')
	email = email_links[0]['href'] unless email_links[0].nil?	
	if email.nil?
		emails_array << "email not provided"
		puts "eamil not provided"
		#puts "email no. #{index} not provided"
	else
		emails_array << email		
		puts "grabbing email..."
		#puts "found email no. #{index}"
	end
end

Capybara.default_wait_time = 60
#Capybara.raise_server_errors = false

#Configure Poltergeist to not blow up on js errors
Capybara.register_driver :poltergeist do |app|
	Capybara::Poltergeist::Driver.new(app, js_errors:false)
end

#Configure Capybara to use Poltergeist as driver
Capybara.default_driver = :poltergeist

# Define global vars
puts "reading csv..."
urls = CSV.read('privateSchoolLinks.csv').first
puts "success"
browser = Capybara.current_session
emails = []
cities = []
provinces = []
websites = []
school_names = []
new_urls = [] 
# phone_numbers = [] 


urls.each_with_index do |url, index|	
	puts "----------------------PAGE #{index}----------------------"
	#-----------NOKAGIRI SCRAPING SECTION------------
	puts "checking errors..."
	res = Net::HTTP.get_response(URI.parse(url))
	if res.code.to_i >= 200 && res.code.to_i < 400 #good codes will be betweem 200 - 399
		# do something with the url
		puts "opening page..."
		page = accessingHTML(url)

		#print console message
		# school_name = page.css("span[itemprop='name']")
		# puts "school no. #{index}: #{school_name.text}"

		#grab school name, city, province, and website and put into array
		puts "grabbing school name..."
		nokagiriiScrape(school_names, school_name=nil, page, "span[itemprop='name']")
		
		puts "grabbing city..."
		nokagiriiScrape(cities, city=nil, page, "span[itemprop='addressLocality']")

		puts "grabbing province..."
		nokagiriiScrape(provinces, province=nil, page, "span[itemprop='addressRegion']")

		puts "grabbing website..."
		website = page.at_css("a[itemprop='url']")
		if website
			websites << website['href']
		else
			websites << "no website provided"
		end

		puts "grabbing url..."
		new_urls << url

		#-----------CAPYBARA SCRAPING SECTION------------
		browser.visit("https://www.schoolguide.co.za/" + url)
		getEmails(browser, emails, index)
	else
	  # skip the object
	  puts "404 Not Found"
	  next
	end
	# phone = browser.all 'table.zebra > tbody > tr:nth-child(6) > td:nth-child(2) > span:nth-child(1)'
	# phone.first.click
	# number = browser.all 'tbody > tr > td > span > span'
	# phone_numbers << number
end

CSV.open("school_scraping.csv", "w") do |csv|
	puts "Writing to csv..."
	csv << school_names
	csv << emails
	csv << cities
	csv << provinces
	csv << websites
	csv << new_urls
	puts "Success"
end

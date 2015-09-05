require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'pry'
require 'capybara/poltergeist'

def accessingHTML(page)
	Nokogiri::HTML(open(page))
end

def nokagiriiScrape(array, var, page, css)
	var = page.css(css)
	if var
		array << var.text
		puts var.text
	else
		array << "no #{var} provided"
		puts "no #{var} provided"
	end
end

def getEmails(browser, url, emails_array)
	browser.visit url
	email_links = browser.all 'tbody tr td span a' 
	email = email_links[0]['href'] unless email_links[0].nil?	
	if email.nil?
		emails_array << "email not provided"
		puts "eamil not provided"
		#puts "email no. #{index} not provided"
	else
		emails_array << email		
		puts "found email: #{email}"
	end
end

#Configure Poltergeist to not blow up on js errors
Capybara.register_driver :poltergeist do |app|
	Capybara::Poltergeist::Driver.new(app, js_errors:false,timeout:90)
end

#Configure Capybara to use Poltergeist as driver
Capybara.default_driver = :poltergeist

browser = Capybara.current_session

# Define global vars
puts "reading csv..."
urls = CSV.read('gautengPages.csv').first
puts urls.length
urls = urls[2431..2700]
puts "success"

emails = []
cities = []
provinces = []
websites = []
school_names = []
new_urls = [] 

urls.each_with_index do |url, index|	
	puts "----------------------PAGE #{index}----------------------"

	#-----------NOKAGIRI SCRAPING SECTION------------
	puts "checking errors..."
	begin
		res = Net::HTTP.get_response(URI.parse(url))
	# URI error check
	rescue URI::InvalidURIError => error
		puts "Bad URI"
		next
	end
	# URL error check
	if res.code.to_i >= 200 && res.code.to_i < 400 #good codes will be betweem 200 - 399
		# do something with the url
		puts "opening page..."
		page = accessingHTML(url)

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
			puts website['href']
			websites << website['href']
		else
			websites << "no website provided"
		end

		puts "grabbing url..."
		puts url
		new_urls << url

		#-----------CAPYBARA SCRAPING SECTION------------
		getEmails(browser, url, emails)

	else
		# skip the object
		puts "404 Not Found"
		next
	end
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





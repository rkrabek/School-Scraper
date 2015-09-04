require 'capybara/poltergeist'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'pry'

def accessingHTML(page)
	Nokogiri::HTML(open(page))
end

# def getEmails(browser, emails_array, index)
# 	email_links = browser.all('tbody tr td span a')
# 	email = email_links[0]['href'] unless email_links[0].nil?	
# 	if email.nil?
# 		emails_array << "email not provided"
# 		puts "email no. #{index} not provided"
# 	else
# 		emails_array << email
# 		puts "found email no. #{index}"
# 	end
# end

# Capybara.default_wait_time = 60

# #Configure Poltergeist to not blow up on js errors
# Capybara.register_driver :poltergeist do |app|
# 	Capybara::Poltergeist::Driver.new(app, js_errors:false)
# end

# #Configure Capybara to use Poltergeist as driver
# Capybara.default_driver = :poltergeist

# #Define global vars
# browser = Capybara.current_session

puts "reading csv..."
urls = CSV.read('westernCapeLinks.csv').first
puts "success"

# emails = []
cities = []
provinces = []
websites = []
school_names = []
# phone_numbers = [] 

urls.each_with_index do |url, index|
	page = accessingHTML(url)

	# browser.visit("https://www.schoolguide.co.za/" + url)
	# getEmails(browser, emails, index)
	
	puts school_name = page.css('article div div h1 span').text
	if school_name
		school_names << school_name
	else
		school_names << "no school name provided"
	end
	
	puts city = page.css('table.zebra tbody tr:nth-child(3) td:nth-child(2) a:nth-child(1)').first.text
	if city
		cities << city
	else
		cities << "no city provided" 
	end

	puts province = page.css('table.zebra tbody tr:nth-child(4) td:nth-child(2) a:nth-child(1)').first.text
	if province
		provinces << province
	else
		province = "no province provided"
		provinces << province
	end

	puts website = page.css('table tbody tr td a.jrButtonLink').first['href']
	if website
		websites << website
	else
		websites << "no website provided"
	end
	
	# phone = browser.all 'table.zebra > tbody > tr:nth-child(6) > td:nth-child(2) > span:nth-child(1)'
	# phone.first.click
	# number = browser.all 'tbody > tr > td > span > span'
	# phone_numbers << number
end

CSV.open("school_scraping.csv", "w") do |csv|
	puts "Writing to csv..."
	csv << school_names
	# csv << emails
	# csv << cities
	# csv << provinces
	# csv << websites
	puts "Success"
end





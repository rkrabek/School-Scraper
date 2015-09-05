require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'

def accessingHTML(page)
	Nokogiri::HTML(open(page))
end

#format school and province lists so they can be plugged into url (i.e. downcase and hyphonated)
def formatLists(array, option)
	if option.text.include? " "
		formatted_option = option.text.downcase.gsub!(/\s+/, '-')
	else
		formatted_option = option.text.downcase
	end
	array << formatted_option
end

#get school and province lists
def getLists(url, provinces, school_type)
	page = accessingHTML(url)
	#get school type list
	page.css("body div.tab-content div#school-location-search select#categories option").each do |option|
		formatLists(school_type, option)
	end
	#get provinces list 
	page.css("body div.tab-content div#school-location-search select#jr_province option").each do |option|
		formatLists(provinces, option)
	end
end

#get the total number of pages from the text at the top of the page that lists total results
def getNumPages(home_page)
	num_results = nil
	get_results_string = home_page.css("section div div div div.jrCol4.jrPagenavResults").text.gsub(/^ ([0-9])+/)
	#get result out of nokagiri enumerator into a variable
	get_results_string.each do |extracted_string|
		num_results = extracted_string.split.first.to_i
	end
	#return total number of pages
	return num_pages = (num_results.to_f/10).ceil
end

def getProvincePages(url_first, url_second, array)
	page_number = 1
	page = accessingHTML(url_first + "#{page_number}" + url_second)
	
	num_pages = getNumPages(page)
	while page_number <= num_pages
		page_url = url_first + "#{page_number}" + url_second
		array << page_url
		puts "stored province page #{page_number}"
		page_number += 1
	end
end

def getPrivateSchoolPages(url_first, url_second, array, provinces)
	provinces.each do |province|
		page_num = 1
		page =  accessingHTML(url_first + "#{page_num}" + url_second + province) 
		puts "---------------------------#{province.upcase}-------------------------------"
		puts url_first + "#{page_num}" + url_second + province

		num_pages = getNumPages(page)
		
		while page_num <= num_pages
			page_url = url_first + "#{page_num}" + url_second + province
			puts "storred private school #{province} page #{page_num}"
			array << page_url
			page_num += 1
		end
	end
end

def getSchoolLinks(array_of_pages, array)
	link_count=1
	array_of_pages.each do |url|
		page = accessingHTML(url)
		links_element = page.css('tr td div div a')
		links_element.each do |element|
			link = "https://www.schoolguide.co.za/" + element['href']
			if link.end_with? ".html"
				array << link
				puts "got link no. #{link_count}"
				link_count+=1
			end
		end
	end
end

#instantiate list vars and get lists
provinces = []
school_type = []
home_url = "https://www.schoolguide.co.za/"
getLists(home_url, provinces, school_type)

provinces.shift
school_type.shift

#instantiate Western Cape array and get pages
westernCapePages = []
url_first = "https://www.schoolguide.co.za/all-in/search-results.html?page="
url_second = "&order=featured&query=all&jr_province=western-cape"
getProvincePages(url_first, url_second, westernCapePages)

#instantiate Gauteng array and get pages
gautengPages = []
url_first = "https://www.schoolguide.co.za/all-in/search-results.html?page="
url_second = "&order=featured&query=all&jr_province=gauteng"
getProvincePages(url_first, url_second, gautengPages)

#instantiate Private School array and get pages
privatSchoolPages = []
url_first = "https://www.schoolguide.co.za/schools/private-schools/search-results.html?page="
url_second = "&order=featured&query=all&jr_province="
getPrivateSchoolPages(url_first, url_second, privatSchoolPages, provinces)

westernCapeLinks = []
privateSchoolLinks = []
gautengSchoolLinks = []

link_count = 1

#Get links from pages
getSchoolLinks(westernCapePages, westernCapeLinks)
getSchoolLinks(privatSchoolPages, privateSchoolLinks)
getSchoolLinks(gautengPages, gautengSchoolLinks)

#write Western Cape links to CSV
CSV.open("westernCapeLinks.csv", "w") do |csv|
  puts "writing Western Cape pages to CSV..."
  csv << westernCapeLinks
  puts "success"
end

#write Gauteng links to CSV
CSV.open("gautengPages.csv", "w") do |csv|
  puts "writing Gauteng pages to CSV..."
  csv << gautengSchoolLinks
  puts "success"
end

#write private school links to CSV
CSV.open("privateSchoolLinks.csv", "w") do |csv|
  puts "writing private school pages to CSV..."
  csv << privateSchoolLinks
  puts "success"
end

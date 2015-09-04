require 'capybara/poltergeist'
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end
Capybara.default_driver = :poltergeist

browser = Capybara.current_session
url = "https://www.schoolguide.co.za/schools/private-schools/vision-afrika-primary-school.html"
browser.visit url
email_link = browser.find 'tbody tr td span a'
email = email_link['href']
puts email
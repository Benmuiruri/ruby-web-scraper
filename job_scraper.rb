# frozen_string_literal: true

require 'nokogiri'
require 'selenium-webdriver'
require 'open-uri'

URL = 'https://news.ycombinator.com/item?id=35424807'
KEYWORDS = %w[Ruby Remote Rails].freeze
OUTPUT_FILE = 'job_postings.txt'

def filtered_jobs(document, keywords)
  jobs = document.css('tr.athing td.default div.comment span.commtext')
  jobs.select { |job| keywords.any? { |keyword| job.text.downcase.include?(keyword.downcase) } }
end

def setup_driver
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  Selenium::WebDriver.for(:chrome, options: options)
end

def load_all_comments(driver, url)
  driver.get(url)
  loop do
    more_jobs_link = driver.find_elements(:xpath, '//a[contains(text(), "more comments")]').first
    break if more_jobs_link.nil?

    more_jobs_link.click
    sleep 3
  end
  Nokogiri::HTML(driver.page_source)
ensure
  driver&.quit
end

def write_job_postings_to_file(job_postings, output_file)
  File.open(output_file, 'w') do |file|
    if job_postings.empty?
      file.write("No job postings found with the specified keywords.\n")
    else
      file.write("Found #{job_postings.length} job postings\n")
      job_postings.each_with_index do |job, index|
        file.write("Job posting #{index + 1}: #{job.text.strip}\n\n")
      end
    end
  end
end

def main
  driver = setup_driver
  document = load_all_comments(driver, URL)
  job_postings = filtered_jobs(document, KEYWORDS)
  write_job_postings_to_file(job_postings, OUTPUT_FILE)
  puts "Results of #{job_postings.length} jobs have been written to #{OUTPUT_FILE}."
rescue StandardError => e
  puts "An error occurred while trying to scrape the pages: #{e.message}"
end

main

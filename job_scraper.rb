# frozen_string_literal: true

require 'httparty'
require 'nokogiri'

KEYWORDS = %w[Ruby Rails EMEA].freeze
JOB_POSTINGS_FILE = 'job_postings.txt'
PAGES_TO_SCRAPE = 5

# PageRetriever is responsible for fetching an HTML document from a given URL
class PageRetriever
  def self.fetch(url)
    response = HTTParty.get(url)

    raise "Unable to fetch the page, response code: #{response.code}" unless response.success?

    Nokogiri::HTML(response.body)
  rescue StandardError => e
    puts "Error occurred while fetching jobs: #{e.message}"
  end
end

# JobScraper is responsible for scraping job postings from a website
class JobScraper
  # TextHelper is responsible for cleaning text and HTML
  class TextHelper
    def self.clean_text(text)
      text.gsub(/\s+/, ' ').strip
    end

    def self.clean_html(html)
      html.gsub(/<[^>]*>/, '')
    end
  end

  # JobFilter is responsible for filtering job postings based on given keywords
  class JobFilter
    def self.filter(document)
      return [] unless document

      document.css('tr.athing.comtr').each_with_object([]) do |job_post, acc|
        acc << job_post if keyword_present_in_text?(job_post.text)
      end
    end

    def self.keyword_present_in_text?(text)
      KEYWORDS.any? { |keyword| text.include?(keyword) }
    end
  end

  # JobDetailsExtractor is responsible for extracting details from job postings
  class JobDetailsExtractor
    def self.extract(comment)
      {
        title: TextHelper.clean_text(comment.css('.hnuser').text),
        time: TextHelper.clean_text(comment.css('.age a').text),
        details: TextHelper.clean_text(TextHelper.clean_html(comment.css('.commtext').inner_html))
      }
    end
  end

  # JobFormatter is responsible for formatting job postings for output
  class JobFormatter
    def self.format(job_postings)
      output = ["Found #{job_postings.count} job postings"]
      job_postings.each_with_index do |posting, index|
        output << "Job posting #{index + 1}: #{posting[:title]} | #{posting[:time]}\n#{posting[:details]}\n"
      end
      output.join("\n")
    end
  end

  def initialize
    @all_jobs = []
  end

  def scrape_jobs
    retrieve_all_jobs
    cleaned_jobs = @all_jobs.map { |job| JobDetailsExtractor.extract(job) }
    save_jobs(JobFormatter.format(cleaned_jobs))
  end

  private

  def retrieve_all_jobs
    puts "Scraping #{PAGES_TO_SCRAPE} pages for jobs with keywords: #{KEYWORDS.join(', ')}"
    (1..PAGES_TO_SCRAPE).each do |page|
      url = "https://news.ycombinator.com/item?id=43243024&p=#{page}"
      document = PageRetriever.fetch(url)
      @all_jobs += JobFilter.filter(document)
    end
  end

  def save_jobs(jobs, job_file = JOB_POSTINGS_FILE)
    File.open(job_file, 'w') { |file| file.write(jobs) }
    puts "Found #{@all_jobs.count} jobs and saved them to #{JOB_POSTINGS_FILE}"
  rescue StandardError => e
    puts "Error occurred while saving jobs: #{e.message}"
  end
end

JobScraper.new.scrape_jobs

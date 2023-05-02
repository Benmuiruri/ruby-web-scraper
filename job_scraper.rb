require 'httparty'
require 'nokogiri'

KEYWORDS = ["React", "Ruby", "Rails"]

def fetch_jobs(page)
  url = "https://news.ycombinator.com/item?id=35773707&p=#{page}"
  unparsed_page = HTTParty.get(url)
  Nokogiri::HTML(unparsed_page)
end

def filtered_jobs(document, keywords)
  job_posts = document.css("tr.athing.comtr")

  job_posts.select do |job_post|
    text = job_post.text
    keywords.any? { |keyword| text.include?(keyword) }
  end
end

def clean_text(text)
  text.gsub(/\s+/, ' ').strip
end

def extract_job_details(comment)
  {
    title: clean_text(comment.css('.hnuser').text),
    time: clean_text(comment.css('.age a').text),
    details: clean_text(comment.css('.commtext').inner_html.gsub(/<[^>]*>/, ''))
  }
end

def formatted_job_postings(job_postings)
  output = "Found #{job_postings.count} job postings\n"
  job_postings.each_with_index do |posting, index|
    output << "Job posting #{index + 1}: #{posting[:title]} | #{posting[:time]}\n#{posting[:details]}\n\n"
  end
  output
end

def save_jobs(jobs)
  File.open("job_postings.txt", "w") do |file|
    file.write(jobs)
  end
end

# Scrape the first 3 pages
pages_to_scrape = 3
all_jobs = []

(1..pages_to_scrape).each do |page|
  document = fetch_jobs(page)
  jobs = filtered_jobs(document, KEYWORDS)
  all_jobs += jobs
end

cleaned_jobs = all_jobs.map { |job| extract_job_details(job) }
formatted_jobs = formatted_job_postings(cleaned_jobs)
save_jobs(formatted_jobs)

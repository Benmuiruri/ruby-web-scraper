# Ruby Job Scraper 🕷️

A simple Ruby-based web scraper designed to help developers filter through job postings on the HackerNews job board, specifically targeting Ruby and Rails jobs.

## Table of Contents

- [Ruby Job Scraper 🕷️](#ruby-job-scraper-️)
  - [Table of Contents](#table-of-contents)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
  - [Usage](#usage)
  - [Contributing](#contributing)
  - [License](#license)
  - [Acknowledgements](#acknowledgements)

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- Ruby (tested on version 2.7.0 or later)
- Bundler

### Installation

1. Clone the repo - `git clone https://github.com/Benmuiruri/ruby-web-scraper.git`

2. Install required gems - `bundle install`


## Usage

1. Open `job_scraper.rb` and customize the constants `URL`, `KEYWORDS`, and `OUTPUT_FILE`. _get the HackerNews jobs board url for the current month_
2. Run the script - `ruby job_scraper.rb`
3. Check the output file (`job_postings.txt` by default) for the filtered job postings.

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add YourFeature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a pull request

## License

Distributed under the MIT License.

## Acknowledgements

- [Nokogiri](https://nokogiri.org/)
- [Selenium](https://www.selenium.dev/)
- [open-uri](https://ruby-doc.org/stdlib-2.7.0/libdoc/open-uri/rdoc/OpenURI.html)



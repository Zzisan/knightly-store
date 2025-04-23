# Medieval Products Scraper

This scraper collects product data from medievalcollectibles.com to populate the Knightly e-commerce application with realistic medieval product data.

## Features

- Scrapes multiple categories of medieval products (swords, shields, helmets, etc.)
- Extracts product names, descriptions, prices, and images
- Handles pagination to scrape multiple pages per category
- Saves data to a CSV file for easy importing
- Includes Rake tasks for scraping and importing

## Usage

### Scraping Products

To scrape products and save them to a CSV file:

```bash
rake scrape:products
```

This will:
1. Scrape the first 2-3 pages of each configured category
2. Extract product details (name, description, price, image URL, etc.)
3. Save the results to `products.csv` in the root directory

### Importing Products

To import the scraped products into the database:

```bash
rake scrape:import
```

This will:
1. Read the `products.csv` file
2. Create or update products in the database
3. Download and attach product images
4. Set appropriate attributes (price, sale status, etc.)

### Scrape and Import in One Step

To scrape and import in a single command:

```bash
rake scrape:all
```

### Using with Seeds

You can also use the scraped data with the Rails seeds:

```bash
rails db:seed
```

The main seeds file will load the products seed file, which will import the scraped data if available.

## Configuration

You can configure the scraper by editing the `lib/tasks/scrape_products.rb` file:

- `CATEGORIES`: The categories to scrape and their URLs
- `PAGES_PER_CATEGORY`: Number of pages to scrape per category
- `CSV_FILE`: The output CSV file path

## Notes

- The scraper includes random delays between requests to avoid being blocked
- It handles errors gracefully and includes retry logic
- The import process sets random stock quantities for each product
- Products with missing required fields are skipped

## Legal Considerations

This scraper is intended for educational purposes only. Please respect the website's terms of service and robots.txt file. Consider the following:

1. Use the data only for personal/educational projects
2. Do not overload the target website with requests
3. Do not use the scraped data for commercial purposes without permission

## Troubleshooting

If you encounter issues:

1. Check that the target website structure hasn't changed
2. Ensure you have the required gems installed (nokogiri, httparty)
3. Try reducing the number of pages scraped per category
4. Check the logs for specific error messages
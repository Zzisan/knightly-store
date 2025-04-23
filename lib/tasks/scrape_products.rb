require 'nokogiri'
require 'httparty'
require 'csv'
require 'uri'
require 'logger'

# Initialize logger
logger = Logger.new(STDOUT)
logger.level = Logger::INFO

# Categories to scrape with their URLs
CATEGORIES = {
  'Swords' => 'https://www.medievalcollectibles.com/product-category/weaponry/swords/',
  'Shields' => 'https://www.medievalcollectibles.com/product-category/armor/shields/',
  'Helmets' => 'https://www.medievalcollectibles.com/product-category/armor/helmets/',
  'Axes' => 'https://www.medievalcollectibles.com/product-category/weaponry/axes/',
  'Daggers' => 'https://www.medievalcollectibles.com/product-category/weaponry/daggers/',
  'Body Armor' => 'https://www.medievalcollectibles.com/product-category/armor/body-armour/',
  'Gauntlets' => 'https://www.medievalcollectibles.com/product-category/armor/gauntlets/'
}

# Number of pages to scrape per category
PAGES_PER_CATEGORY = 2

# Output CSV file
CSV_FILE = 'products.csv'

# User agent to mimic a browser
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'

# Method to fetch a page with retry logic
def fetch_page(url, retries = 3)
  begin
    # Add a random delay to avoid being blocked (1-3 seconds)
    sleep(1 + rand(2))
    
    # Make the HTTP request with headers to mimic a browser
    response = HTTParty.get(
      url,
      headers: {
        'User-Agent' => USER_AGENT,
        'Accept' => 'text/html,application/xhtml+xml,application/xml',
        'Accept-Language' => 'en-US,en;q=0.9'
      },
      timeout: 30
    )
    
    # Check if the request was successful
    if response.code == 200
      Nokogiri::HTML(response.body)
    else
      if retries > 0
        logger.warn("Request failed with status #{response.code}. Retrying... (#{retries} attempts left)")
        fetch_page(url, retries - 1)
      else
        logger.error("Failed to fetch #{url} after multiple attempts")
        nil
      end
    end
  rescue => e
    if retries > 0
      logger.warn("Error fetching #{url}: #{e.message}. Retrying... (#{retries} attempts left)")
      fetch_page(url, retries - 1)
    else
      logger.error("Failed to fetch #{url} after multiple attempts: #{e.message}")
      nil
    end
  end
end

# Method to extract product details from a product page
def extract_product_details(product_url, category)
  logger.info("Extracting details from: #{product_url}")
  
  # Fetch the product page
  doc = fetch_page(product_url)
  return nil unless doc
  
  # Initialize product hash
  product = {
    'name' => nil,
    'description' => nil,
    'category' => category,
    'price' => nil,
    'sale_price' => nil,
    'image_url' => nil
  }
  
  # Extract product name
  name_element = doc.at_css('.product_title')
  product['name'] = name_element.text.strip if name_element
  
  # Extract product description
  description_element = doc.at_css('.woocommerce-product-details__short-description, #tab-description')
  if description_element
    # Clean up the description text
    product['description'] = description_element.text.strip.gsub(/\s+/, ' ')
  end
  
  # Extract price
  price_element = doc.at_css('.price .woocommerce-Price-amount')
  if price_element
    # Remove currency symbol and convert to float
    price_text = price_element.text.strip.gsub(/[^\d.]/, '')
    product['price'] = price_text.to_f
    product['sale_price'] = price_text.to_f # Default to same as price
  end
  
  # Check for sale price
  sale_price_element = doc.at_css('.price ins .woocommerce-Price-amount')
  if sale_price_element
    sale_price_text = sale_price_element.text.strip.gsub(/[^\d.]/, '')
    product['sale_price'] = sale_price_text.to_f
    
    # If there's a sale price, the regular price is in the 'del' element
    regular_price_element = doc.at_css('.price del .woocommerce-Price-amount')
    if regular_price_element
      regular_price_text = regular_price_element.text.strip.gsub(/[^\d.]/, '')
      product['price'] = regular_price_text.to_f
    end
  end
  
  # Extract image URL
  image_element = doc.at_css('.woocommerce-product-gallery__image img')
  if image_element
    # Try to get the high-resolution image URL
    product['image_url'] = image_element['src'] || image_element['data-src'] || image_element['data-large_image']
  end
  
  # Validate that we have all required fields
  required_fields = ['name', 'description', 'category', 'price', 'image_url']
  missing_fields = required_fields.select { |field| product[field].nil? || product[field].to_s.empty? }
  
  if missing_fields.any?
    logger.warn("Skipping product due to missing fields: #{missing_fields.join(', ')}")
    return nil
  end
  
  product
end

# Method to scrape products from a category page
def scrape_category_page(url, category)
  logger.info("Scraping category page: #{url}")
  
  # Fetch the category page
  doc = fetch_page(url)
  return [] unless doc
  
  products = []
  
  # Find all product links on the page
  product_links = doc.css('.products .product a.woocommerce-LoopProduct-link')
  
  product_links.each do |link|
    product_url = link['href']
    next unless product_url
    
    # Extract product details
    product = extract_product_details(product_url, category)
    products << product if product
    
    # Break after 5 products per page to avoid overloading the server
    break if products.size >= 5
  end
  
  products
end

# Method to get the next page URL
def get_next_page_url(doc, base_url)
  next_page_link = doc.at_css('.next.page-numbers')
  return nil unless next_page_link
  
  next_page_url = next_page_link['href']
  return nil unless next_page_url
  
  # Ensure the URL is absolute
  URI.join(base_url, next_page_url).to_s
end

# Main scraping method
def scrape_products
  all_products = []
  
  CATEGORIES.each do |category, url|
    logger.info("Starting to scrape category: #{category}")
    
    current_url = url
    page_count = 0
    
    while current_url && page_count < PAGES_PER_CATEGORY
      # Fetch the category page
      doc = fetch_page(current_url)
      break unless doc
      
      # Scrape products from the current page
      products = scrape_category_page(current_url, category)
      all_products.concat(products)
      
      # Get the next page URL
      current_url = get_next_page_url(doc, current_url)
      page_count += 1
      
      logger.info("Scraped #{products.size} products from page #{page_count} of #{category}")
    end
  end
  
  # Save products to CSV
  save_to_csv(all_products)
  
  logger.info("Scraping completed. Total products scraped: #{all_products.size}")
end

# Method to save products to CSV
def save_to_csv(products)
  logger.info("Saving #{products.size} products to #{CSV_FILE}")
  
  CSV.open(CSV_FILE, 'w') do |csv|
    # Write header
    csv << ['name', 'description', 'category', 'price', 'sale_price', 'image_url']
    
    # Write product data
    products.each do |product|
      csv << [
        product['name'],
        product['description'],
        product['category'],
        product['price'],
        product['sale_price'],
        product['image_url']
      ]
    end
  end
  
  logger.info("CSV file saved successfully")
end

# Run the scraper
scrape_products
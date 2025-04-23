namespace :scrape do
  desc "Scrape medieval products from medievalcollectibles.com"
  task :products => :environment do
    require_relative 'scrape_products'
    puts "Starting to scrape products..."
    scrape_products
    puts "Scraping completed!"
  end
  
  desc "Import scraped products into the database"
  task :import => :environment do
    require 'csv'
    
    puts "Importing products from CSV..."
    
    # Check if the CSV file exists
    csv_file = Rails.root.join('products.csv')
    unless File.exist?(csv_file)
      puts "Error: products.csv file not found. Please run rake scrape:products first."
      exit
    end
    
    # Track statistics
    stats = {
      total: 0,
      imported: 0,
      skipped: 0,
      errors: 0
    }
    
    # Import products
    CSV.foreach(csv_file, headers: true) do |row|
      stats[:total] += 1
      
      begin
        # Find or initialize a new product
        product = Product.find_or_initialize_by(name: row['name'])
        
        # Find or create the category
        category = Category.find_or_create_by(name: row['category'])
        
        # Set product attributes
        product.description = row['description']
        product.category = category
        product.price = row['price'].to_f
        
        # Check if the product is on sale
        if row['sale_price'].to_f < row['price'].to_f
          product.on_sale = true
          product.sale_price = row['sale_price'].to_f
          product.discount_percentage = ((1 - (row['sale_price'].to_f / row['price'].to_f)) * 100).round
        else
          product.on_sale = false
          product.sale_price = product.price
          product.discount_percentage = 0
        end
        
        # Set stock quantity randomly between 5 and 50
        product.stock_quantity = rand(5..50)
        
        # Save the product
        if product.save
          stats[:imported] += 1
          
          # Download and attach the image if there's an image URL
          if row['image_url'].present? && !product.image.attached?
            begin
              # Download the image
              require 'open-uri'
              downloaded_image = URI.open(row['image_url'])
              
              # Generate a filename from the URL
              filename = File.basename(URI.parse(row['image_url']).path)
              
              # Attach the image to the product
              product.image.attach(io: downloaded_image, filename: filename)
              puts "Attached image to product: #{product.name}"
            rescue => e
              puts "Error attaching image to product #{product.name}: #{e.message}"
            end
          end
        else
          stats[:errors] += 1
          puts "Error saving product #{row['name']}: #{product.errors.full_messages.join(', ')}"
        end
      rescue => e
        stats[:errors] += 1
        puts "Error processing row: #{e.message}"
      end
    end
    
    # Print statistics
    puts "Import completed!"
    puts "Total rows: #{stats[:total]}"
    puts "Products imported: #{stats[:imported]}"
    puts "Errors: #{stats[:errors]}"
  end
  
  desc "Scrape products and import them into the database"
  task :all => [:products, :import] do
    puts "Scraping and importing completed!"
  end
end
# db/seeds.rb
# Simplified seed file with Faker data for medieval products

require 'faker'

# ========= Clear Existing Data =========
puts "Clearing existing data..."
OrderItem.delete_all if defined?(OrderItem)
Order.delete_all if defined?(Order)
Product.delete_all
Category.delete_all

# ========= Seeding Categories =========
puts "Seeding Categories..."
categories = {}
[
  "Swords", 
  "Shields", 
  "Axes", 
  "Armor", 
  "Helmets", 
  "Daggers", 
  "Accessories"
].each do |cat_name|
  categories[cat_name] = Category.create!(
    name: cat_name,
    description: "Exquisite collection of #{cat_name.downcase} for noble warriors."
  )
end

# ========= Category-specific content =========
category_content = {
  "Swords" => {
    prefixes: ["Ancient", "Mystic", "Dragon's", "Valiant", "Enchanted", "Royal", "Knight's"],
    base_names: ["Sword", "Blade", "Sabre", "Rapier", "Broadsword", "Longsword", "Claymore"],
    suffixes: ["of Power", "of Legends", "of Destiny", "of the Fallen", "of Eternal Flame"],
    descriptions: [
      "Forged in ancient fires, this weapon gleams with magical brilliance.",
      "A formidable blade known to vanquish even the strongest foes.",
      "This sword carries the legend of a once-great knight.",
      "Balanced and deadly, this blade has tasted the blood of many enemies."
    ]
  },
  "Shields" => {
    prefixes: ["Lionheart", "Ironclad", "Unyielding", "Fortified", "Brave", "Stalwart"],
    base_names: ["Shield", "Buckler", "Aegis", "Defender", "Bulwark", "Kite Shield"],
    suffixes: ["Protector", "Defender", "Bastion", "Sentinel", "Guardian"],
    descriptions: [
      "A robust shield that stands as a bulwark against enemy strikes.",
      "Adorned with symbols of valor, this shield inspires courage.",
      "Tested in the heat of battle, offering formidable defence.",
      "This shield has turned aside countless blows in service to its bearer."
    ]
  },
  "Axes" => {
    prefixes: ["Brutal", "Mighty", "Berserker's", "Dwarven", "Battle-worn"],
    base_names: ["Axe", "Battle Axe", "War Axe", "Hatchet", "Double-Axe", "Tomahawk"],
    suffixes: ["of Rage", "of the Mountain", "of Splitting", "of Fury", "Cleaver"],
    descriptions: [
      "A heavy axe capable of cleaving through armor with ease.",
      "This fearsome weapon strikes terror into the hearts of enemies.",
      "Balanced for both throwing and close combat, this axe is versatile.",
      "The blade of this axe never dulls, no matter how many foes it fells."
    ]
  },
  "Armor" => {
    prefixes: ["Sturdy", "Impenetrable", "Celestial", "Legendary", "Guardian", "Knight's"],
    base_names: ["Armor", "Plate", "Mail", "Hauberk", "Breastplate", "Cuirass"],
    suffixes: ["of Valor", "of Kings", "of Might", "of the Ancients", "of Fortitude"],
    descriptions: [
      "Intricately crafted to provide both unmatched protection and style.",
      "Armor that has been passed down through generations of warriors.",
      "Built to withstand the perils of battle, yet light on the shoulders.",
      "The finest smiths in the realm labored for months to create this masterpiece."
    ]
  },
  "Helmets" => {
    prefixes: ["Visored", "Plated", "Commander's", "Royal", "Crusader's"],
    base_names: ["Helmet", "Helm", "Greathelm", "Sallet", "Bascinet", "Armet"],
    suffixes: ["of Sight", "of Protection", "of Command", "of the Vigilant", "of Focus"],
    descriptions: [
      "This helmet offers superior protection while maintaining visibility.",
      "Adorned with the crest of a noble house, this helmet marks its wearer as elite.",
      "The visor can be raised or lowered depending on the needs of battle.",
      "Despite its sturdy construction, this helmet is surprisingly comfortable."
    ]
  },
  "Daggers" => {
    prefixes: ["Silent", "Assassin's", "Poisoned", "Ceremonial", "Jeweled"],
    base_names: ["Dagger", "Dirk", "Stiletto", "Kris", "Rondel", "Misericorde"],
    suffixes: ["of Shadows", "of Swiftness", "of the Serpent", "of Precision", "of Venom"],
    descriptions: [
      "A concealed weapon perfect for surprise attacks or self-defense.",
      "The blade is etched with runes that seem to absorb light.",
      "This dagger's balance makes it ideal for throwing or close combat.",
      "Though small, this blade can find gaps in even the heaviest armor."
    ]
  },
  "Accessories" => {
    prefixes: ["Noble", "Regal", "Ceremonial", "Eternal", "Enchanted", "Blessed"],
    base_names: ["Gauntlets", "Circlet", "Medallion", "Signet", "Brooch", "Amulet", "Ring"],
    suffixes: ["of Honor", "of Wisdom", "of the Realm", "of Power", "of Mystery"],
    descriptions: [
      "An exquisite accessory, a mark of noble heritage.",
      "Crafted with precision, offering both elegance and utility.",
      "A treasured piece that carries a legacy of honor and tradition.",
      "This item is said to bring good fortune to its bearer in times of need."
    ]
  }
}

# ========= Load Product Photos =========
puts "Loading product photos from app/assets/images/product_photos..."
product_photos_dir = Rails.root.join("app", "assets", "images", "product_photos")
product_photos = Dir.glob(File.join(product_photos_dir, "*.{jpg,jpeg,png,avif}"))

if product_photos.empty?
  puts "No product photos found in app/assets/images/product_photos. Using placeholder images instead."
  # Use placeholder.jpg as fallback
  placeholder_path = Rails.root.join("app", "assets", "images", "placeholder.jpg")
  product_photos = [placeholder_path] if File.exist?(placeholder_path)
end

puts "Found #{product_photos.size} product photos"

# ========= Seeding Products =========
puts "Seeding 50 Medieval Products..."
50.times do |i|
  # Randomly choose a category
  category_name = categories.keys.sample
  category = categories[category_name]
  content = category_content[category_name]
  
  # Generate product name
  prefix = content[:prefixes].sample
  base_name = content[:base_names].sample
  suffix = content[:suffixes].sample
  product_name = "#{prefix} #{base_name} #{suffix}"
  
  # Generate description
  base_description = content[:descriptions].sample
  additional_text = Faker::Lorem.sentence(word_count: 8)
  product_description = "#{base_description} #{additional_text}"
  
  # Determine if product is on sale (30% chance)
  on_sale = [true, false, false].sample
  
  # Set price and sale price
  price = Faker::Commerce.price(range: 100.0..2000.0).round(2)
  sale_price = nil
  
  if on_sale
    discount = rand(10..40)
    sale_price = (price * (100 - discount) / 100.0).round(2)
  end
  
  # Create the product
  product = Product.create!(
    name: product_name,
    description: product_description,
    price: price,
    sale_price: sale_price,
    stock_quantity: Faker::Number.between(from: 1, to: 50),
    category: category,
    on_sale: on_sale
  )
  
  # Select a random image from the product_photos directory
  if product_photos.any?
    begin
      # Choose a random image
      image_path = product_photos.sample
      
      # Open the file and prepare for attachment
      file = File.open(image_path)
      filename = File.basename(image_path)
      
      # Determine content type based on file extension
      content_type = case File.extname(filename).downcase
                     when '.jpg', '.jpeg' then 'image/jpeg'
                     when '.png' then 'image/png'
                     when '.avif' then 'image/avif'
                     else 'image/jpeg'
                     end
      
      # Attach the image to the product
      product.image.attach(
        io: file,
        filename: filename,
        content_type: content_type
      )
      
      puts "Created product #{i+1}: #{product.name} in category #{category.name} with image: #{filename}"
      
      # Close the file
      file.close
    rescue => e
      puts "Error attaching image to product #{product.name}: #{e.message}"
    end
  else
    puts "Created product #{i+1}: #{product.name} in category #{category.name} (no images available)"
  end
end

puts "Seeding complete: #{Category.count} Categories, #{Product.count} Products created."

# ========= Seed Provinces =========
puts "Seeding Provinces..."
Province.destroy_all
[
  { name: "Ontario",                    gst_rate: 0.05,   pst_rate: 0.08,    hst_rate: 0.13 },
  { name: "Quebec",                     gst_rate: 0.05,   pst_rate: 0.09975, hst_rate: 0.0  },
  { name: "British Columbia",           gst_rate: 0.05,   pst_rate: 0.07,    hst_rate: 0.0  },
  { name: "Alberta",                    gst_rate: 0.05,   pst_rate: 0.0,     hst_rate: 0.0  },
  { name: "Nova Scotia",                gst_rate: 0.0,    pst_rate: 0.0,     hst_rate: 0.15 },
  { name: "Manitoba",                   gst_rate: 0.05,   pst_rate: 0.07,    hst_rate: 0.0  },
  { name: "Saskatchewan",               gst_rate: 0.05,   pst_rate: 0.06,    hst_rate: 0.0  },
  { name: "New Brunswick",              gst_rate: 0.0,    pst_rate: 0.0,     hst_rate: 0.15 },
  { name: "Newfoundland & Labrador",    gst_rate: 0.0,    pst_rate: 0.0,     hst_rate: 0.15 },
  { name: "Prince Edward Island",       gst_rate: 0.0,    pst_rate: 0.0,     hst_rate: 0.15 },
  { name: "Yukon",                      gst_rate: 0.05,   pst_rate: 0.0,     hst_rate: 0.0  },
  { name: "Northwest Territories",      gst_rate: 0.05,   pst_rate: 0.0,     hst_rate: 0.0  },
  { name: "Nunavut",                    gst_rate: 0.05,   pst_rate: 0.0,     hst_rate: 0.0  }
].each do |attrs|
  Province.create!(attrs)
end
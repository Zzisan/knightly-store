# db/seeds.rb

require 'faker'
require 'open-uri'
require 'cgi'

# Load specific seed files
Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each do |seed|
  puts "Loading seed file: #{File.basename(seed)}"
  load seed
end

# ========= Custom Arrays: Base Names & Descriptions =========

# Base names for each category
SWORD_NAMES = [
  "Sword", "Blade", "Sabre", "Rapier", "Broadsword"
]

ARMOUR_NAMES = [
  "Armour", "Plate", "Mail", "Hauberk", "Breastplate"
]

SHIELD_NAMES = [
  "Shield", "Buckler", "Aegis", "Defender", "Bulwark"
]

ACCESSORIES_NAMES = [
  "Gauntlets", "Circlet", "Medallion", "Signet", "Brooch"
]

# Base descriptions for each category
SWORD_DESCRIPTIONS = [
  "Forged in ancient fires, this weapon gleams with magical brilliance.",
  "A formidable blade known to vanquish even the strongest foes.",
  "This sword carries the legend of a once-great knight."
]

ARMOUR_DESCRIPTIONS = [
  "Intricately crafted to provide both unmatched protection and style.",
  "Armour that has been passed down through generations of warriors.",
  "Built to withstand the perils of battle, yet light on the shoulders."
]

SHIELD_DESCRIPTIONS = [
  "A robust shield that stands as a bulwark against enemy strikes.",
  "Adorned with symbols of valor, this shield inspires courage.",
  "Tested in the heat of battle, offering formidable defence."
]

ACCESSORIES_DESCRIPTIONS = [
  "An exquisite accessory, a mark of noble heritage.",
  "Crafted with precision, offering both elegance and utility.",
  "A treasured piece that carries a legacy of honor and tradition."
]

# ========= Additional Arrays: Prefixes and Suffixes =========

# For Swords
SWORD_PREFIXES = ["Ancient", "Mystic", "Dragon's", "Valiant", "Enchanted"]
SWORD_SUFFIXES = ["of Power", "of Legends", "of Destiny", "of the Fallen", "of Eternal Flame"]

# For Armour
ARMOUR_PREFIXES = ["Sturdy", "Impenetrable", "Celestial", "Legendary", "Guardian"]
ARMOUR_SUFFIXES = ["of Valor", "of Kings", "of Might", "of the Ancients", "of Fortitude"]

# For Shields
SHIELD_PREFIXES = ["Lionheart", "Ironclad", "Unyielding", "Fortified", "Brave"]
SHIELD_SUFFIXES = ["Protector", "Defender", "Bastion", "Sentinel", "Guardian"]

# For Accessories
ACCESSORIES_PREFIXES = ["Noble", "Regal", "Ceremonial", "Eternal", "Enchanted"]
ACCESSORIES_SUFFIXES = ["of Honor", "of Wisdom", "of the Realm", "of Power", "of Mystery"]

# ========= Generic Fallback Arrays =========

GENERIC_NAMES = ["Mystic Relic", "Ancient Artifact", "Legendary Item"]
GENERIC_DESCRIPTIONS = [
  "A mysterious item shrouded in legend.",
  "An artifact with origins lost in the mists of time.",
  "A prized possession of nobility and magic."
]

# ========= Clear Existing Data =========

puts "Clearing existing data..."
OrderItem.delete_all if defined?(OrderItem)
Order.delete_all if defined?(Order)
Product.delete_all
Category.delete_all

# ========= Seeding Categories =========

puts "Seeding Categories..."
categories = {}
["Swords", "Armour", "Shields", "Accessories"].each do |cat_name|
  categories[cat_name] = Category.create!(
    name: cat_name,
    description: "Exquisite collection of #{cat_name.downcase} for noble warriors."
  )
end

# ========= Load Product Photos =========

photos = Dir.glob(Rails.root.join("app", "assets", "images", "product_photos", "*.{jpg,png}"))
if photos.empty?
  puts "No product photos found in app/assets/images/product_photos. Please add some images."
end

# ========= Seeding Medieval Products =========

puts "Seeding 100 Medieval Products..."
100.times do |i|
  # Randomly choose a category name and its object
  chosen_category_name = ["Swords", "Armour", "Shields", "Accessories"].sample
  category = categories[chosen_category_name]

  # Compose product name based on category using additional arrays
  final_name = case chosen_category_name
               when "Swords"
                 "#{SWORD_PREFIXES.sample} #{SWORD_NAMES.sample} #{SWORD_SUFFIXES.sample}"
               when "Armour"
                 "#{ARMOUR_PREFIXES.sample} #{ARMOUR_NAMES.sample} #{ARMOUR_SUFFIXES.sample}"
               when "Shields"
                 "#{SHIELD_PREFIXES.sample} #{SHIELD_NAMES.sample} #{SHIELD_SUFFIXES.sample}"
               when "Accessories"
                 "#{ACCESSORIES_PREFIXES.sample} #{ACCESSORIES_NAMES.sample} #{ACCESSORIES_SUFFIXES.sample}"
               else
                 GENERIC_NAMES.sample
               end

  final_description = case chosen_category_name
                      when "Swords"
                        "#{SWORD_DESCRIPTIONS.sample} #{Faker::Lorem.sentence(word_count: 5)}"
                      when "Armour"
                        "#{ARMOUR_DESCRIPTIONS.sample} #{Faker::Lorem.sentence(word_count: 5)}"
                      when "Shields"
                        "#{SHIELD_DESCRIPTIONS.sample} #{Faker::Lorem.sentence(word_count: 5)}"
                      when "Accessories"
                        "#{ACCESSORIES_DESCRIPTIONS.sample} #{Faker::Lorem.sentence(word_count: 5)}"
                      else
                        GENERIC_DESCRIPTIONS.sample
                      end

  # Randomly decide if this product is on sale and set a discount percentage accordingly
  sale_status = [true, false].sample
  discount = sale_status ? rand(5..30) : 0

  product = Product.create!(
    name: final_name,
    description: final_description,
    price: Faker::Commerce.price(range: 100.0..2000.0),
    stock_quantity: Faker::Number.between(from: 1, to: 50),
    category: category,
    on_sale: sale_status,
    discount_percentage: discount
  )

  # Attach a random image from your product_photos folder if available
  if photos.any?
    begin
      file = File.open(photos.sample)
      product.image.attach(io: file, filename: File.basename(file), content_type: "image/jpeg")
      file.close
      puts "Created product #{i+1}: #{product.name} in category #{category.name} with an image."
    rescue => e
      puts "Created product #{i+1}: #{product.name} in category #{category.name} but failed to attach image: #{e.message}"
    end
  else
    puts "Created product #{i+1}: #{product.name} in category #{category.name} (no image attached)"
  end
end

puts "Seeding complete: #{Category.count} Categories, #{Product.count} Products created."
# ========= STEP 6: SEED PROVINCES =========
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
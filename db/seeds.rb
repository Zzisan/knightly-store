# db/seeds.rb

require 'faker'
require 'open-uri'
require 'cgi'

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
Category.destroy_all
Product.destroy_all

# ========= Seeding Categories =========

puts "Seeding Categories..."
categories = {}
["Swords", "Armour", "Shields", "Accessories"].each do |cat_name|
  categories[cat_name] = Category.create!(
    name: cat_name,
    description: "Exquisite collection of #{cat_name.downcase} for noble warriors."
  )
end

# ========= Seeding Medieval Products =========

puts "Seeding 100 Medieval Products..."
100.times do |i|
  # Randomly choose a category name and object
  chosen_category_name = ["Swords", "Armour", "Shields", "Accessories"].sample
  category = categories[chosen_category_name]

  # Compose product name and description based on category with additional arrays
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

  product = Product.create!(
    name: final_name,
    description: final_description,
    price: Faker::Commerce.price(range: 100.0..2000.0),
    stock_quantity: Faker::Number.between(from: 1, to: 50),
    category: category
  )

  puts "Created product #{i+1}: #{product.name} in category #{category.name}"
end

puts "Seeding complete: #{Category.count} Categories, #{Product.count} Products created."

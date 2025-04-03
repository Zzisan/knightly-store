class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  
  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "description", "created_at", "updated_at"]
  end
  
  # ... any other code
end

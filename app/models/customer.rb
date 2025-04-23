class Customer < ApplicationRecord
  # Devise modules and any other configuration
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :orders, dependent: :destroy
  belongs_to :province, optional: true
  
  # Ransack: Allowlist searchable attributes
  def self.ransackable_attributes(auth_object = nil)
    ["id", "email", "first_name", "last_name", "phone", "address", "created_at", "updated_at"]
  end

  # Ransack: Allowlist associations for filtering
  def self.ransackable_associations(auth_object = nil)
    ["orders"]
  end
end

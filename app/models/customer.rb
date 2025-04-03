class Customer < ApplicationRecord
  # Devise modules (add more if needed)
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :orders, dependent: :destroy
end

# app/models/page.rb

class Page < ApplicationRecord
    # If you have validations, add them here. For example:
    # validates :title, :slug, :content, presence: true
  
    # Ransack allowlisting
    def self.ransackable_attributes(auth_object = nil)
      [
        "id",
        "title",
        "slug",
        "content",
        "created_at",
        "updated_at"
      ]
    end
  
    def self.ransackable_associations(auth_object = nil)
      # List any associations you'd like to allow searching/filtering on.
      # If Page doesn't have associations, leave it as an empty array.
      []
    end
  end
  
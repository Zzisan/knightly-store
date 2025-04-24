class PagesController < ApplicationController
  def show
    @page = Page.find_by(slug: params[:slug])
    if @page.nil?
      # Render a 404 or redirect to another page if no matching Page is found
      render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
    end
  end
end

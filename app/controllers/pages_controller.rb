class PagesController < ApplicationController
  def show
    @page = Page.find_by(slug: params[:slug])
    if @page.nil?
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
  end
end

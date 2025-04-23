
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,        keys: [:address, :province_id])
    devise_parameter_sanitizer.permit(:account_update, keys: [:address, :province_id])
  end
  allow_browser versions: :modern
end

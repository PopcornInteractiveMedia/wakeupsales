module DeviseHelper

  def devise_error_messages!   
     flash[:alert] = resource.errors.full_messages.first+"." if resource.errors.present?
  end
end

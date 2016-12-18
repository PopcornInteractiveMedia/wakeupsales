module MailerHelper
  def track(name, email, obj_id)
    SentEmail.create!(:name => name, :email => email, :sent => DateTime.now)
    url = "#{root_path(:only_path => false)}email/track/#{Base64.urlsafe_encode64("name=#{name}&email=#{email}&activity_id=#{obj_id}")}.png"
    raw("<img src=\"#{url}\" alt='' width=\"1\" height=\"1\">")
  end
end
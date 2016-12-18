class NotifyMoveWonDeal
  include Sidekiq::Worker
  
  def perform(org_id,deal_id,user_name)
      @admin_email = User.where("organization_id=? and admin_type =?",org_id,2)
      @deal = Deal.find deal_id.to_i
      @admin_email.each do |a_email|
       puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
       Notification.won_deal_notification(a_email.email,@deal,user_name).deliver 
     end  
  end
end


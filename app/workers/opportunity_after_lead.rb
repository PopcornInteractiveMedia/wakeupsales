class OpportunityAfterLead
  include Sidekiq::Worker
  
  def perform()    
      deal = Deal.where(:is_csv => true).where(:is_mail_sent => false)
       deals = DealsController.new
       #puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
       #p deal
       if deal.present?
         deal.each do |dl|
           puts "#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
           p dl
           deals.insert_deal_activity(dl)
           #deals.insert_opportunities(dl)
         end
       end
  end 
    
end





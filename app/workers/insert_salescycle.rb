class InsertSalescycle
  include Sidekiq::Worker
  
  def perform(deal_id)    
      puts "=========          perform(deal)              ==================="
      deal = Deal.find deal_id.to_i
      deals = DealsController.new
      deals.insert_salescycle(deal)
      puts "----- updating ---------"
  end 
    
end





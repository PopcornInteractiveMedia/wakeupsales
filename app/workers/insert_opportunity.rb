class InsertOpportunity
  include Sidekiq::Worker
  
  def perform(deal_id)    
      puts "=========          perform(deal)              ==================="
      if deal_id
        deal = Deal.find deal_id.to_i
        deals = DealsController.new        
        deals.insert_opportunities(deal)
      end
      puts "----- finished ---------"
  end 
    
end





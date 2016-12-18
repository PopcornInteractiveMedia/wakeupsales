class AttentionDealWorker
  include Sidekiq::Worker
  
  def perform(user)
    current_user=User.where("id=?", user).first
    deals=[]
    if current_user.present?
      if current_user.is_admin? || current_user.is_super_admin?
#        tire.search(load: true) do
#          query { string params[:query]} if params[:query].present?
#        end
       deals = Tire.search [ 'deals'], :load => true do
        filter :term, :organization_id => current_user.organization_id
        to_hash[:filter] = { :and => to_hash[:filter] }
       end
        deals = current_user.organization.deals
      else
        deals = current_user.my_deals
      end
      deals = deals.includes(:deal_status).select("deals.id, deals.created_at").where("deal_statuses.original_id IN(?) and is_active=?",[1,2], true)
      attention_deals = fetch_attention(deals, current_user) if deals.present?
      if attention_deals.present?
        ids=attention_deals.map{|bar| bar.id}
        if current_user.attention_deal.present?
          current_user.attention_deal.update_attributes(deal_ids: (ids.present? ? ids : []), deal_count: attention_deals.count)
        else
          AttentionDeal.create!(organization_id: current_user.organization_id, user_id: current_user.id, deal_ids: (ids.present? ? ids : []), deal_count: attention_deals.count)
        end
        puts "-----------channel value----------------"
        channel="/messages/new/#{current_user.id}"
        p channel
#        PrivatePub.publish_to(channel, status: "success")
      end
    end
  end
  
  def fetch_attention(deals, current_user)
    attention_deals=[]
    deals.each do |d|
      attention_deals << d if d.need_attention?(current_user)
    end
  end
end





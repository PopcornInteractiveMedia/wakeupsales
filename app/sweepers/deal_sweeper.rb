class DealSweeper < ActionController::Caching::Sweeper
  #observe Deal

  def after_save(deal)
      expire_cache_for(deal)
  end

  def after_update(deal)
      expire_cache_for(deal)
  end

  def after_destroy(deal)  
      expire_cache_for(deal)
  end

  private
  
    def expire_cache_for(record)
      @controller ||= ActionController::Base.new
      expire_action(:controller => 'deals', :action => 'show', :id =>record.id)
      
      
      puts "---------->expire_cache_for <--------------------"
  #    ss
      #expire_fragment "listings/#{record.id}-#{record.updated_at.to_i}"
      #Rails.logger.debug "***\n>>> Listing #{record.id} cache fragment expired!\n***" if Rails.env.development?
    end

end

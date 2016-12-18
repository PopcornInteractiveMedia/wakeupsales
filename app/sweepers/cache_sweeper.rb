class CacheSweeper < ActionController::Caching::Sweeper
  #observe :deal, :task
  
  def after_create(record)
      expire_cache_for(record) if record.class.name == "Task"
  end

  def after_save(record)
      expire_cache_for(record) if record.class.name == "Task"
  end

  def after_update(record)
      expire_cache_for(record)
  end

  def after_destroy(record)  
      expire_cache_for(record)
  end

  private
  
    def expire_cache_for(record)
      @controller ||= ActionController::Base.new
      if record.class.name == "Task"
        record_id = record.taskable.present? ? record.taskable.id : ""
      else
         record_id = record.id
      end
      expire_action(:controller => 'deals', :action => 'show', :id =>record_id)
      
      
      puts "---------->expire_cache_for <--------------------"
  #    ss
      #expire_fragment "listings/#{record.id}-#{record.updated_at.to_i}"
      #Rails.logger.debug "***\n>>> Listing #{record.id} cache fragment expired!\n***" if Rails.env.development?
    end

end

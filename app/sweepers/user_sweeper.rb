class UserSweeper < ActionController::Caching::Sweeper
  observe User

  def after_save(user)
    expire_fragment 'organization_users'
    expire_fragment 'organization_users_task'
    expire_fragment "user_menu_#{user.id}"
  end

  # FIXME: Remove after_update. Method after_save is doing the same thing
  def after_update(user)
    expire_fragment "organization_users"
    expire_fragment "organization_users_task"
  end

  def after_destroy(user)  
    expire_fragment "organization_users"
    expire_fragment "organization_users_task"
  end

  #def expire_cache(fragment_name)
  #end
  
end

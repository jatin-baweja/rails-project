class UserSweeper < ActionController::Caching::Sweeper
  # observe User

  # def after_update(user)
  #   expire_cache(user)
  # end

  # def after_destroy(user)
  #   expire_cache(user)
  # end

  # def expire_cache(user)
  #   expire_action controller: :users, action: :show, id: user
  # end

end
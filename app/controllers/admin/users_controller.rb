class Admin::UsersController < Admin::AdminApplicationController

  def index
    @users = User.all
  end

end
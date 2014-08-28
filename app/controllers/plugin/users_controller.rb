class Plugin::UsersController < PluginController

  include UsersHelper

  def new
    session[:return_to] = plugin_path
    @user = User.new(gender: "Female")
  end

  def create
    @user = User.new(params[:user])

    if create_user @user
      wishes = ActiveSupport::JSON.decode(cookies[:wishes]).map do |w|
        item = Item.create!(
          title: w['title'],
          image: w['picture'],
          link:  w['link'],
          price: w['price'].to_i
        )

        Wish.create! title: item.title, item_id: item.id
      end

      @list = @user.lists.first
      @list.wishes << wishes
      cookies.delete :wishes

      redirect_to plugin_list_path(@list)
    else
      render 'new'
    end
  end

end

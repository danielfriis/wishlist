class Plugin::SessionsController < PluginController

  def new
    session[:return_to] = plugin_path
  end

  def destroy
    sign_out
    redirect_to plugin_path
  end

end
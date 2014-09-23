class SearchSuggestions
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["PATH_INFO"] == "/item_suggestion"
      request = Rack::Request.new(env)
      items = Item.search(request.params["query"]).popular
      [200, {"Content-Type" => "application/json"}, [items.to_json(include: :vendor, methods: :base_uri)]]
    elsif env["PATH_INFO"] == "/user_suggestion"
      request = Rack::Request.new(env)
      users = User.search(request.params["query"]).most_followers
      [200, {"Content-Type" => "application/json"}, [users.to_json(methods: :base_uri)]]
    elsif env["PATH_INFO"] == "/vendor_suggestion"
      request = Rack::Request.new(env)
      vendors = Vendor.search(request.params["query"]).most_followers
      [200, {"Content-Type" => "application/json"}, [vendors.to_json(methods: :base_uri)]]
    else
      @app.call(env)
    end
  end
end
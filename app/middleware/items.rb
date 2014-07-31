class Items
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["PATH_INFO"] == "/search_suggestion"
      request = Rack::Request.new(env)
      items = Item.search(request.params["query"]).popular
      [200, {"Content-Type" => "application/json"}, [items.to_json(include: :vendor)]]
    else
      @app.call(env)
    end
  end
end
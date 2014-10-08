xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
  xml.url do
    xml.loc "http://www.halusta.com"
    xml.priority 1.0
  end

  @static_paths.each do |url|
    xml.url do
      xml.loc "#{url}"
      xml.priority 0.9
      xml.changefreq("monthly")
    end
  end
  @items.each do |item|
    xml.url do
      xml.loc "#{item_url(item)}"
      xml.priority 0.8
      xml.lastmod item.updated_at.strftime("%F")
      xml.changefreq("monthly")
    end
  end
  @users.each do |user|
    xml.url do
      xml.loc "#{user_url(user)}"
      xml.priority 0.7
      xml.lastmod user.updated_at.strftime("%F")
      xml.changefreq("monthly")
    end
  end
end
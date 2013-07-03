module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Wishlistt"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def avatar(user, size)
  	if user.avatar_url("#{size}").nil?
  		"#{root_url}/assets/default_#{size.to_s}.jpg"
  	else
  		user.avatar_url("#{size}")
  	end
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    if column == params[:sort]
      css_class = "active"
    elsif params[:sort] == nil && column == "recent"
      css_class = "active"
    end
    # css_class = column == params[:sort] ? "active" : nil
    link_to title, {:sort => column}, {:class => css_class}
  end

end
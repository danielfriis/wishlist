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

  def sortable_general(column, title = nil)
    title ||= column.titleize
    if params[:sort] == nil && column == "recent"
      css_class = "active"
    elsif column == params[:sort]
      css_class = "active"
    else
      css_class = nil
    end
    link_to title, {:sort => column, :gender => sort_gender}, {:class => css_class}
  end

  def sortable_gender(gender, title = nil)
    title ||= gender.titleize
    if params[:gender] == nil && gender == "all"
      css_class = "active"
    elsif gender == params[:gender]
      css_class = "active"
    else
      css_class = nil
    end
    link_to title, {:sort => sort_general, :gender => gender}, :class => "btn #{css_class}"
  end

  def nav_link(link_text, link_path)
    css_class = current_page?(link_path) ? 'active' : ''
    link_to link_text, link_path, class: "#{css_class}" 
  end

    def meta_keywords(tags = nil)
    if tags.present?
      content_for :meta_keywords, tags
    else
      content_for?(:meta_keywords) ? [content_for(:meta_keywords), APP_CONFIG['meta_keywords']].join(', ') : APP_CONFIG['meta_keywords']
    end
  end

  def meta_description(desc = nil)
    if desc.present?
      content_for :meta_description, desc
    else
      content_for?(:meta_description) ? content_for(:meta_description) : APP_CONFIG['meta_description']
    end
  end

  # def sortable(column, title = nil)
  #   title ||= column.titleize
  #   css_class = column == sort_column ? "current #{sort_direction}" : nil
  #   direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
  #   link_to title, {:sort => column, :gender => gender}, {:class => css_class}
  # end 

end
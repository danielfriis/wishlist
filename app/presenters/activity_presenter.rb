class ActivityPresenter < SimpleDelegator
	attr_reader :activity

	def initialize(activity, view)
		super(view)
		@activity = activity
	end

  def render_activity
    div_for activity, class: "media" do
    	content_tag(:div, render_avatar, class: "pull-left") +
      content_tag(:div, content_tag(:strong, render_user) + " " + render_partial, class: "media-body")
    end
  end

  def render_avatar
  	image_tag avatar(activity.user, :small), alt: activity.user.name, class: "gravatar gravatar-small img-rounded"
  end

  def render_user
  	link_to(activity.user.name, activity.user, class: 'muted')
  end

	def render_partial
		locals = { activity: activity, presenter: self }
		locals[activity.trackable_type.underscore.to_sym] = activity.trackable
		render partial_path, locals
	end

	def partial_path
		"activities/#{activity.trackable_type.underscore}/#{activity.action}"
	end

end
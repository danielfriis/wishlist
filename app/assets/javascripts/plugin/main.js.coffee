$ ->

  $.cookie.defaults =
    path: '/'
    expires: 365

  # cookieSettings =
  #   path: '/'
  #   domain: 'localhost'

  getWishes = -> $.cookie('wishes') || []

  console.log getWishes()

  persistWishes = (wishes, cb) ->
    if $.cookie 'wishes', wishes
      console.log 'Saved wishes'
      if cb?
        cb()
      else
        true
    else
      console.log 'Failed to save wishes:'
      console.log wishes
      false

  addListener = ->
    $('.remove-item').click (e) ->
      title = $(e.target).data 'title'
      wishes = []

      for wish in getWishes()
        unless wish.title is title
          wishes.push wish
        else
          console.log "removed: #{title}"

      persistWishes wishes, renderWishes

  clearWishes = (cb) ->
    if $.removeCookie 'wishes'
    # if persistWishes []
      console.log 'Removed wishes'
      if cb?
        cb()
      else
        true
    else
      console.log 'Failed to clear wishes'
      false


  $('.clear-list').click (e) ->
    clearWishes -> window.location.reload()

  $('.lists li')
    .on('mouseover', ->
        return if not colors?
        $(this).css backgroundColor: colors.background
        $(this).css color: colors.foreground
    )
    .on('mouseout', ->
        return if not colors?
        $(this).css backgroundColor: 'initial'
        $(this).css color: 'initial'
    )

  $('.new-list').on 'click', '.show-create-list, .cancel', ->
    $('.new-list .show-create-list').toggle()
    $('.new-list .create-list').toggle()

  renderWishes = ->
    wishes = getWishes()
    $('.wishes').html ''

    # extract domain
    isSignedIn = $('.wishes-top.signed-in').length > 0
    if isSignedIn and wishes.length > 1
      $('.wishes').hide()
      $('.wishes-text').text "Adding #{wishes.length} wishes"
    else
      $('.clear-list').hide()

    for wish in wishes
      matches = wish.link.match(/^https?\:\/\/(www.)?([^\/?#:]+)/i);
      domain = matches and matches[2]

      $('.wishes').append """
        <li>
          <div class="remove-item" data-title="#{wish.title}">x</div>
          <img alt="" height="60" src="#{wish.picture}" width="60">
          <p class="title">#{wish.title}</p>
          <p class="from">from <strong>#{domain}</strong></p>
        </li>
        <hr/>
      """

    addListener()

    console.log 'Rendered wishes'

  colors = null
  window.onmessage = (e) ->
    colors = e.data.colors
    $('.bg-color').css 'backgroundColor', colors.background
    $('.fg-color').css 'color', colors.foreground
    wish = e.data.wish
    wishes = getWishes()

    console.log "Message: #{wish.title}"

    titles = wishes.map (wish) -> wish.title
    unless wish.title in titles
      wishes.push wish
      console.log "Added: #{wish.title}"

    persistWishes wishes, renderWishes

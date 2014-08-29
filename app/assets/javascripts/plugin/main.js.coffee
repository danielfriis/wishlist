$ ->
  $.cookie.json = yes
  $.cookie.defaults =
    path: '/'
    expires: 365

  getWishes = -> $.cookie('wishes') || []

  persistWishes = (wishes, cb) ->
    if $.cookie 'wishes', wishes
      if cb?
        cb()
      else
        true
    else
      false

  addListener = ->
    $('.remove-item').click (e) ->
      title = $(e.target).data 'title'
      wishes = []

      for wish in getWishes()
        unless wish.title is title
          wishes.push wish

      persistWishes wishes, renderWishes

  clearWishes = (cb) ->
    if $.removeCookie 'wishes'
      if cb?
        cb()
      else
        true
    else
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
          <img alt="" height="60" src="#{wish.image}" width="60">
          <p class="title">#{wish.title}</p>
          <p class="from">from <strong>#{domain}</strong></p>
        </li>
        <hr/>
      """

    addListener()

  colors = null

  window.onmessage = (e) ->
    data = JSON.parse e.data
    colors = data.colors
    $('.bg-color').css 'backgroundColor', colors.background
    $('.fg-color').css 'color', colors.foreground
    wish = data.wish
    wishes = getWishes()

    titles = wishes.map (wish) -> wish.title
    unless wish.title in titles
      wishes.push wish

    persistWishes wishes, renderWishes

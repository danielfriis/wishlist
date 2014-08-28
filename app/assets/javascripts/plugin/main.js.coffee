$ ->

  $('.clear-list').click (e) ->
    if $.removeCookie 'wishes'
      window.location.reload()

  $('.lists li')
    .on('mouseover', -> $(this).addClass 'active')
    .on('mouseout', -> $(this).removeClass 'active')

  $('.new-list').on 'click', '.show-create-list, .cancel', ->
    $('.new-list .show-create-list').toggle()
    $('.new-list .create-list').toggle()

  renderWishes = (wishes) ->
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

    $('.remove-item').click (e) ->
      title = $(e.target).data 'title'
      console.log title
      wishes = []

      for wish in $.cookie('wishes')
        unless wish.title is title
          wishes.push wish
        else
          console.log "removed: #{title}"
      $.cookie 'wishes', wishes

      renderWishes wishes


  window.onmessage = (e) ->
    wish = e.data
    wishes = ($.cookie 'wishes') || []

    if wishes.length > 0
      titles = wishes.map (wish) -> wish.title
      unless wish.title in titles
        wishes.push wish
        $.cookie 'wishes', wishes
    else
      wishes.push wish
      $.cookie 'wishes', [wish]

    renderWishes wishes

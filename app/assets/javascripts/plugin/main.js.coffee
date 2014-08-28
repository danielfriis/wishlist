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

  window.onmessage = (e) ->
    wish = e.data
    wishes = ($.cookie 'wishes') || []

    if wishes?
      titles = wishes.map (wish) -> wish.title
      unless wish.title in titles
        wishes.push(wish)
        $.cookie 'wishes', wishes
    else
      $.cookie 'wishes', [wish]

    # extract domain
    isSignedIn = $('.wishes-top.signed-in').length > 0
    if isSignedIn and wishes.length > 1
        $('.wishes').hide()
        $('.wishes-text').text "Adding #{wishes.length} wishes"

    for wish in wishes
        matches = wish.link.match(/^https?\:\/\/(www.)?([^\/?#:]+)/i);
        domain = matches and matches[2]

        $('.wishes').append """
            <li>
                <img alt="Whale" height="60" src="#{wish.picture}" width="60">
                <p class="title">#{wish.title}</p>
                <p class="from">from <strong>#{domain}</strong></p>
            </li>
            <hr/>
        """

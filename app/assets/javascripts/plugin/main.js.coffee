$ ->

  $('.clear-list').click (e) ->
    if $.removeCookie 'wishes'
      console.log 'Cookie removed'
    else
      console.log 'Failed to remove cookie'

  $('.lists li')
    .on('mouseover', -> $(this).addClass 'active')
    .on('mouseout', -> $(this).removeClass 'active')

  $('.new-list').on 'click', '.show-create-list, .cancel', ->
    $('.new-list .show-create-list').toggle()
    $('.new-list .create-list').toggle()

  window.onmessage = (e) ->
    wish = e.data
    wishes = $.cookie 'wishes'

    console.log "Message:"
    console.log wish
    console.log "Cookie:"
    console.log wishes

    if wishes?
      titles = wishes.map (wish) -> wish.title
      unless wish.title in titles
        wishes.push(wish)
        $.cookie 'wishes', wishes
        console.log 'Wish added to cookie'
      else
        return
    else
      $.cookie 'wishes', [wish]
      console.log 'Cookie created'

    # extract domain
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

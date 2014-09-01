#= require jquery

$ ->
    # hide body until we're rendered
    $('body').hide()
    $('body').on 'click', ->
        window.top.postMessage 'show_iframe', '*'

    window.onmessage = (e) ->
        data = JSON.parse(e.data)
        $('.image img').attr src: data.wish.image

        # placement and colors according to config
        $('body').css
            backgroundColor: data.colors.background
            color: data.colors.foreground

        $('body').show()

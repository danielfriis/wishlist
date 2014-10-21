# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
# Infinite scroll

jQuery ->
  if $('#inspiration-pagination').size() > 0
    $(window).on 'scroll', ->
      more_posts_url = $('.pagination .next_page a').attr('href')
      if more_posts_url && $(window).scrollTop() > $(document).height() - $(window).height() - 160
        $('.pagination').html('<img src="/assets/ajax-loader.gif" alt="Loading..." title="Loading..." />')
        $.getScript more_posts_url
      return
    return

jQuery ->
  if $('.scroll-container').size() > 0
    $(".scroll-container").on 'scroll', ->
      more_posts_url = $('.pagination .next_page a').attr('href')
      if more_posts_url && $(".scroll-container").scrollTop() > $(".inspiration").height() - $(".inspiration").height() - 160
        $('.pagination').html('<img src="/assets/ajax-loader.gif" alt="Loading..." title="Loading..." />')
        $.getScript more_posts_url
      return
    return


# jQuery ->
#         isScrolledIntoView = (elem) ->
#                 docViewTop = $(window).scrollTop()
#                 docViewBottom = docViewTop + $(window).height()
#                 elemTop = $(elem).offset().top
#                 elemBottom = elemTop + $(elem).height()
#                 (elemTop >= docViewTop) && (elemTop <= docViewBottom)

#         if $('#inspiration-pagination').children('.pagination').length
#                 $(window).scroll ->
#                         url = $('.pagination .next_page a').attr('href')
#                         if url && isScrolledIntoView('.pagination')
#                                 $('.pagination').text('Fetching more...')
#                                 $.getScript(url)
                
#                 $(window).scroll()
# jQuery ->
#   $(".scroll-container").scroll ->
#     url = $('.pagination .next_page a').attr('href')
#     interval = setInterval () -> 
#       checkScroll()
#     , 10
    
#     checkScroll = () ->
#       if ($(".scroll-container").scrollTop()) > ($(".inspiration").height() - 500) && url
#         clearInterval(interval)
#         $('.pagination').text('Fetching more...')
#         $.getScript(url)
#   $(".scroll-container").scroll()
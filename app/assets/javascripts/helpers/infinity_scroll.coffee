############################################
## Helper file for Infinity Scrolling ######
############################################

$(document).on 'turbolinks:load', ->

  # on scroll, check if element is in view and if so, trigger button click
  $(document).on('scroll', ->
    $("div.infinity_scroll.ready").each ->
      if is_element_visible(@)
        if not $(@).hasClass("in-view")
          $(@).children("a").first().click()
        $(@).addClass("in-view")
      else
        $(@).removeClass("in-view")
  )


  # on click, set loading state
  $("div.infinity_scroll.ready").click ->
    $(@).removeClass('initial error ready').addClass('loading')


  # on successfull ajax call, change the button url and re-ready the button
  $(document).ajaxSuccess (event, xhr, settings) ->

    $("div.infinity_scroll").each ->

      url = $(@).children('a').first().attr('href')

      if settings.url.endsWith( url )

        limit = parseInt $(@).attr('data-page-limit')
        page = parseInt get_parameter_from_url(url, "page")

        if $(@).hasClass('next') and page < limit
          $(@).children('a').first().prop('href', replace_parameter_in_url(url, "page", page+1))

        else if $(@).hasClass('previous') and page > limit
          $(@).children('a').first().attr('href', replace_parameter_in_url(url, "page", page-1))

        else
          $(@).addClass('hide')


        $(@).removeClass('loading').addClass('initial ready')


  # on failed ajax call, show toast and set error state
  $(document).ajaxError (event, xhr, settings) ->

    $("div.infinity_scroll").each ->

      url = $(@).children('a').first().attr('href')

      if settings.url.endsWith( url )

        Application.show_notice "An error occured. Please check your Internet connection and try again."
        $(@).removeClass('loading').addClass('error ready')



  ### Helper Methods ###

  # replaces a parameter in a given url with the given value
  replace_parameter_in_url = (url, parameter, value) ->
    pattern = new RegExp('\\b(' + parameter + '=).*?(&|$)')
    return url.replace(pattern,'$1' + value + '$2')

  # retrieves a given paramater from a url string
  get_parameter_from_url = (url, parameter) ->
    result = null
    tmp = []

    url.split("?")[1].split("&").forEach (item) ->
      tmp = item.split("=")
      if (tmp[0] == parameter) then result = decodeURIComponent(tmp[1])

    return result

  # checks whether a given element is currently visible in the viewport
  # adapted from http://stackoverflow.com/a/15203639/6451879
  is_element_visible = (element) ->
    rect     = element.getBoundingClientRect()
    vWidth   = window.innerWidth || doc.documentElement.clientWidth
    vHeight  = window.innerHeight || doc.documentElement.clientHeight
    efp      = (x, y) ->
      return document.elementFromPoint(x, y)

    # Return false if it's not in the viewport
    if (rect.right < 0 || rect.bottom < 0 || rect.left > vWidth || rect.top > vHeight)
      return false

    # Return true if any of its four corners are visible
    return (element.contains(efp(rect.left,  rect.top)) ||
      element.contains(efp(rect.right-1, rect.top)) ||
      element.contains(efp(rect.right-1, rect.bottom-1)) ||
      element.contains(efp(rect.left,  rect.bottom-1))
    )

  # defines the endsWith function to check if a string ends with a given string
  if typeof String.prototype.endsWith != 'function'
    String.prototype.endsWith = (str) ->
      return @.lastIndexOf(str) == @.length - str.length

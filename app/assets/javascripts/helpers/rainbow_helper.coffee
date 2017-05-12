$(document).on 'turbolinks:render', ->

  # if we are rendering from cache and the page uses the rainbow color scheme
  if document.documentElement.hasAttribute("data-turbolinks-preview") and $("body").hasClass("primary-rainbow")

    # choose new color scheme randomly
    window.new_color_scheme = Color.rainbow_color_schemes()[Math.floor(Math.random()*Color.rainbow_color_schemes().length)]
    window.new_color_scheme += " " + Color.font_color_for window.new_color_scheme
    window.new_color_scheme = "primary-" + window.new_color_scheme.split(" ").join(" primary-")

    # remove old color schem
    for class_name in $("body").attr("class").split(/\s+/)
      if class_name.indexOf("primary-") == 0 and class_name != "primary-rainbow"
        $("body").removeClass class_name

    # add new color scheme and font color
    $("body").addClass window.new_color_scheme

  # if we have set a new color scheme and the page uses the rainbow color scheme
  else if window.new_color_scheme and window.new_color_scheme != null and $("body").hasClass("primary-rainbow")

    # remove old color scheme
    for class_name in $("body").attr("class").split(/\s+/)
      if class_name.indexOf("primary-") == 0 and class_name != "primary-rainbow"
        $("body").removeClass class_name

    # add new color scheme and font color
    $("body").addClass window.new_color_scheme

    # reset the color scheme
    window.new_color_scheme = null

  # otherwise, just reset the color scheme
  else
    window.new_color_scheme = null

class @User

  # Methods
  #
  #/ Static: Public
  #// initialize_color_select: Change shade colors on base color change
  #// initialize_image_upload: Inits and triggers for file upload in a container
  #
  #/ Static: Private
  #// enable_file_removal: Enables the remove-button on a container
  #// enable_file_upload: Enables the upload-button on a container
  #// read_image: Reads an image (from file input) and executes a callback
  #// set_picture: Sets the container's backgroundImage to a given image
  #// set_page_color_scheme

  #########################
  # Static Public Methods #
  #########################

  # Change shade colors on base color change
  @initialize_color_select: ->

    # when base color changes
    $("form#edit_profile div.base_color select").change ->

      new_color = $(@).val()

      # change class on color shade to that of new base color
      $("form#edit_profile div.shade_color select option").
        removeClass(Color.base_colors().join(" ")).
        addClass(new_color)

      # remove unavailable options
      $("form#edit_profile div.shade_color select option").each ->
        shade = $(@).html().toLowerCase().replace(" ", "-")
        if Color.shades_for_color(new_color).indexOf(shade) == -1
          $(@).attr("disabled", true)
        else
          $(@).attr("disabled", false)

      # make sure current value is not disabled
      if $("form#edit_profile div.shade_color select").val() == null
        $("form#edit_profile div.shade_color select").val("basic")

      # re-init material_select
      $("form#edit_profile div.shade_color select").material_select()

    # when base or shade changes, update page color scheme
    $("form#edit_profile div.color_scheme select").change ->

      base_color  = $("form#edit_profile div.base_color select").val()
      shade_color = $("form#edit_profile div.shade_color select").val()

      # remove existing scheme
      $("body").attr("class").split(" ").forEach (body_class) ->
        $("body").removeClass(body_class) if body_class.indexOf("primary") == 0

      font_color = Color.font_color_for("#{base_color} #{shade_color}")
      # add new scheme
      $("body").addClass(
        "primary-#{base_color} primary-#{shade_color} " +
        "primary-#{font_color.split(' ')[0]} primary-#{font_color.split(' ')[1]}"
        )

    # trigger change once to initialize
    $("form#edit_profile div.base_color select").trigger("change")


  # inits and triggers for the file upload within a container
  @initialize_image_upload: (container) ->
    if not $(container).hasClass("default")
      User.enable_file_removal $(container)

    # when upload button is clicked
    $(container).find("input[type='file']").change ->
      $(container).find(".delete_picture").val("false")
      User.enable_file_loading $(container)
      User.read_image(this, (e) ->
        User.set_picture($(container), e.target.result)
        User.enable_file_removal $(container)
      )

    # when remove button is clicked
    $(container).find(".remove").click ->
      $(container).find(".delete_picture").val("true")
      $(container).find("input[type='file']").val('')
      User.set_picture $(container), $(@).parent().attr("data-default-image-url")
      User.enable_file_upload $(container)


  ############################
  #  Private Public Methods  #
  ############################

  # enables uploads for a file input
  @enable_file_upload: (container) ->
    $(container).find(".upload").removeClass("hide")
    $(container).find(".remove").addClass("hide")
    $(container).find(".loading").addClass("hide")

  # enables removal for a file input
  @enable_file_removal: (container) ->
    $(container).find(".remove").removeClass("hide")
    $(container).find(".upload").addClass("hide")
    $(container).find(".loading").addClass("hide")

  # enables loading
  @enable_file_loading: (container) ->
    $(container).find(".loading").removeClass("hide")
    $(container).find(".upload").addClass("hide")
    $(container).find(".remove").addClass("hide")

  # reads an image and executes a callback
  @read_image: (file_input, callback) ->
    if file_input.files and file_input.files[0]
      reader = new FileReader()

      reader.onload = (e) ->
        callback(e)

      reader.readAsDataURL(file_input.files[0])

  # sets the container to a given image
  @set_picture: (container, image) ->
    $(container).css("backgroundImage", "url(#{image})")

# Is user looking at a cached version of the page?
is_cached_page = ->
  $("body").attr("data-is-cached") == "true"


@show_notice = (notice, duration) ->
  Materialize.toast(notice, duration) unless is_cached_page()

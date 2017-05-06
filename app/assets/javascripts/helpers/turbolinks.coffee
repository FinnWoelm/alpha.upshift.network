######################################################
##### Helper file to improve Turbolinks behavior #####
######################################################

# When the user is requesting the same page that they are already visiting, do
# not show a cached version of that page (that will be older than the current
# page) before showing the fresh version.
# This is a two step process:
# 1) Determine if the user is requesting the same page as the one that is
#    already loaded.
# 2) When preview is loaded, replace it again with the current page

$(document).on 'turbolinks:before-visit', (event) ->
  if URLs_match(event.originalEvent.data.url, window.location.href, {pathname: true, host: true})
    window.turbolinks_replace_preview = $("body").clone()

$(document).on 'turbolinks:render', ->
  if window.turbolinks_replace_preview != null and document.documentElement.hasAttribute("data-turbolinks-preview")
    $("body").replaceWith(window.turbolinks_replace_preview)
  window.turbolinks_replace_preview = null

# Test if two URLs match. Match_options can be passed to specify which URL
# elements to test
URLs_match = (URL, URL_to_match, match_options = {protocal: true, host: true, pathname: true, search: true, hash: true}) ->

  u1 = document.createElement("a")
  u1.href = URL
  u2 = document.createElement("a")
  u2.href = URL_to_match

  return false if match_options["protocol"]  and u1.protocol != u2.protocol
  return false if match_options["host"]      and u1.host     != u2.host
  return false if match_options["pathname"]  and u1.pathname != u2.pathname
  return false if match_options["search"]    and u1.search   != u2.search
  return false if match_options["hash"]      and u1.hash     != u2.hash
  return true

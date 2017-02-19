# Helper::RouteRecognizer returns an array of route URLs.
#
# To use this inside your app, call:
# `Helper::RouteRecognizer.get_initial_path_segments`
# This returns an array, e.g.: ['assets','blog','team','faq','users']
# Credits for this work belong to bantic: https://gist.github.com/bantic/5688232

class Helper::RouteRecognizer

  INITIAL_SEGMENT_REGEX = %r{^\/([^\/\(:]+)}

  def self.get_initial_path_segments
    paths = Rails.application.routes.routes.collect {|r| r.path.spec.to_s }
    initial_path_segments ||= begin
      paths.collect{ |path| path[INITIAL_SEGMENT_REGEX, 1] }.compact.uniq
    end
  end

end

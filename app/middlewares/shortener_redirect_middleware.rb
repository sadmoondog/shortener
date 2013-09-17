class ShortenerRedirectMiddleware

  require 'split'

  def initialize(app)
    @app = app
  end

  def call(env)

    if (env["PATH_INFO"] =~ ::Shortener.match_url) && (shortener = ::Shortener::ShortenedUrl.find_by_unique_key($1))
      shortener.track env if ::Shortener.tracking

      uid = ''
      begin
        uid ='u'+env['rack.session']['warden.user.user.key'][1][0].to_s
      rescue
      end
      finished ("buy_view_button")
      [301, {'Location' => shortener.url.gsub('sofitsmeuserid', uid)}, []]
    else
      @app.call(env)
    end

  end
end

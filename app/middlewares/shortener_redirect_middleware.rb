class ShortenerRedirectMiddleware



  def initialize(app)
    @app = app
  end

  def call(env)

    if (env["PATH_INFO"] =~ ::Shortener.match_url) && (shortener = ::Shortener::ShortenedUrl.find_by_unique_key($1))
      data = {}
      uid = new_unique_code
      begin
        thing_id = /t(\d+)sofitsmeuserid/.match(shortener.url)[1].to_i
        t = Thing.find(thing_id)
        data =  {:item_id=>t.item.id, :thing_id=>t.id, :subid=>uid} if t
      rescue
      end



      shortener.track(env, data) if ::Shortener.tracking

      uid +='u'+env['rack.session']['warden.user.user.key'][1][0].to_s rescue 'u0'
      uid += CGI.escape(env['QUERY_STRING']) rescue 'u0'

      begin
        prices = /(p\d{1})/.match(env['QUERY_STRING']).captures
        prices.each do |price|
          case price
            when 'p0'
              track! :p0click
            when 'p1'
              track! :p1click
          end
        end
      rescue
      end

      track! :click, {:identity=>UserIdentity.new(env['rack.session'][Evercookie.hash_name_for_saved][:uid]), :values=>[1]} rescue nil

      [301, {'Location' => shortener.url.gsub('sofitsmeuserid', 'c'+uid)}, []]
    else
      @app.call(env)
    end

  end


  private

  def new_unique_code
    new_code = Digest::SHA1.hexdigest(srand.to_s)[0,10]

    while Shortener::ShortenedClick.find_by_subid(new_code)
      new_code = Digest::SHA1.hexdigest(srand.to_s)[0,10]
    end

    new_code
  end

end

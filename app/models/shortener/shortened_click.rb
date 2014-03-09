require 'geoip'
require 'useragent'

class Shortener::ShortenedClick < ActiveRecord::Base
  belongs_to :shortened_url
  serialize :custom_data

  GeoIPDataPath = File.absolute_path File.join(__FILE__, "../../../../config")

  def track (env, data={})

    cookies_data = env['HTTP_COOKIE'].split("\;").map{|str| str.split("=")}.map{|arr| {arr[0]=>arr[1]}}.reduce Hash.new, :merge
    path = Addressable::URI.parse(env['REQUEST_URI']).path.split('/').reject!{|val| val.blank?}
    # logger.info(env)
    self.user_id = env['rack.session']['warden.user.user.key'][1][0] rescue nil
    self.session_id = cookies_data['_session_id'] rescue nil
    self.uuid = cookies_data['uuid'] rescue nil
    self.custom_data = data unless data.blank?
    self.remote_ip = (env["HTTP_X_FORWARDED_FOR"] || env["REMOTE_ADDR"]).to_s
    self.referer = env["HTTP_REFERER"].to_s
    self.agent = env["HTTP_USER_AGENT"].to_s
    self.country = geo_ip.country(self.remote_ip).country_name.to_s
    self.browser = user_agent.browser.to_s
    self.platform = user_agent.platform.to_s
    self.subid = data[:subid] unless data.blank?

    return self.subid

  end

  def user_agent
    @user_agent ||= UserAgent.parse(self.agent)
  end

  def geo_ip
    @geo_ip ||= GeoIP.new(File.join(GeoIPDataPath, 'GeoIP.dat'))
  end

  def geo_lite_city
    @geo_ip ||= GeoIP.new(File.join(GeoIPDataPath, 'GeoLiteCity.dat'))
  end



end

module Shortener::ShortenerHelper

  # generate a url from a url string
  def short_url(url, args = {})
    shortener = Shortener::ShortenedUrl.generate!(url, args)
    shortener ? URI.join(root_url, Shortener.clean_url_prefix, shortener.unique_key).to_s : url
  end

  def short_url_param(url, param)
    shortener = Shortener::ShortenedUrl.generate!(url)
    shortener ? URI.join(root_url, Shortener.clean_url_prefix,  "/#{shortener.unique_key}", "?"+param.map{|key, val| "#{key}#{val}"}.join("")) : url
  end

end

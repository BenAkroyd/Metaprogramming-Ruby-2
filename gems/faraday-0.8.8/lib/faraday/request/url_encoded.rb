#---
# Excerpted from "Metaprogramming Ruby 2",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/ppmetr2 for more book information.
#---
module Faraday
  class Request::UrlEncoded < Faraday::Middleware
    CONTENT_TYPE = 'Content-Type'.freeze

    class << self
      attr_accessor :mime_type
    end
    self.mime_type = 'application/x-www-form-urlencoded'.freeze

    def call(env)
      match_content_type(env) do |data|
        env[:body] = Faraday::Utils.build_nested_query data
      end
      @app.call env
    end

    def match_content_type(env)
      if process_request?(env)
        env[:request_headers][CONTENT_TYPE] ||= self.class.mime_type
        yield env[:body] unless env[:body].respond_to?(:to_str)
      end
    end

    def process_request?(env)
      type = request_type(env)
      env[:body] and (type.empty? or type == self.class.mime_type)
    end

    def request_type(env)
      type = env[:request_headers][CONTENT_TYPE].to_s
      type = type.split(';', 2).first if type.index(';')
      type
    end
  end
end

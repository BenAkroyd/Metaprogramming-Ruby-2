#---
# Excerpted from "Metaprogramming Ruby 2",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/ppmetr2 for more book information.
#---
module Faraday
  class Request::Multipart < Request::UrlEncoded
    self.mime_type = 'multipart/form-data'.freeze
    DEFAULT_BOUNDARY = "-----------RubyMultipartPost".freeze

    def call(env)
      match_content_type(env) do |params|
        env[:request] ||= {}
        env[:request][:boundary] ||= DEFAULT_BOUNDARY
        env[:request_headers][CONTENT_TYPE] += "; boundary=#{env[:request][:boundary]}"
        env[:body] = create_multipart(env, params)
      end
      @app.call env
    end

    def process_request?(env)
      type = request_type(env)
      env[:body].respond_to?(:each_key) and !env[:body].empty? and (
        (type.empty? and has_multipart?(env[:body])) or
        type == self.class.mime_type
      )
    end

    def has_multipart?(obj)
      # string is an enum in 1.8, returning list of itself
      if obj.respond_to?(:each) && !obj.is_a?(String)
        (obj.respond_to?(:values) ? obj.values : obj).each do |val|
          return true if (val.respond_to?(:content_type) || has_multipart?(val))
        end
      end
      false
    end

    def create_multipart(env, params)
      boundary = env[:request][:boundary]
      parts = process_params(params) do |key, value|
        Faraday::Parts::Part.new(boundary, key, value)
      end
      parts << Faraday::Parts::EpiloguePart.new(boundary)

      body = Faraday::CompositeReadIO.new(parts)
      env[:request_headers]['Content-Length'] = body.length.to_s
      return body
    end

    def process_params(params, prefix = nil, pieces = nil, &block)
      params.inject(pieces || []) do |all, (key, value)|
        key = "#{prefix}[#{key}]" if prefix

        case value
        when Array
          values = value.inject([]) { |a,v| a << [nil, v] }
          process_params(values, key, all, &block)
        when Hash
          process_params(value, key, all, &block)
        else
          all << block.call(key, value)
        end
      end
    end
  end
end

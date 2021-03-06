#---
# Excerpted from "Metaprogramming Ruby 2",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/ppmetr2 for more book information.
#---
require 'forwardable'

module Faraday
  class Response
    # Used for simple response middleware.
    class Middleware < Faraday::Middleware
      def call(env)
        @app.call(env).on_complete do |environment|
          on_complete(environment)
        end
      end

      # Override this to modify the environment after the response has finished.
      # Calls the `parse` method if defined
      def on_complete(env)
        if respond_to? :parse
          env[:body] = parse(env[:body]) unless [204,304].index env[:status]
        end
      end
    end

    extend Forwardable
    extend AutoloadHelper
    extend MiddlewareRegistry

    autoload_all 'faraday/response',
      :RaiseError => 'raise_error',
      :Logger     => 'logger'

    register_middleware \
      :raise_error => :RaiseError,
      :logger      => :Logger

    def initialize(env = nil)
      @env = env
      @on_complete_callbacks = []
    end

    attr_reader :env
    alias_method :to_hash, :env

    def status
      finished? ? env[:status] : nil
    end

    def headers
      finished? ? env[:response_headers] : {}
    end
    def_delegator :headers, :[]

    def body
      finished? ? env[:body] : nil
    end

    def finished?
      !!env
    end

    def on_complete
      if not finished?
        @on_complete_callbacks << Proc.new
      else
        yield env
      end
      return self
    end

    def finish(env)
      raise "response already finished" if finished?
      @env = env
      @on_complete_callbacks.each { |callback| callback.call(env) }
      return self
    end

    def success?
      (200..299).include?(status)
    end

    # because @on_complete_callbacks cannot be marshalled
    def marshal_dump
      !finished? ? nil : {
        :status => @env[:status], :body => @env[:body],
        :response_headers => @env[:response_headers]
      }
    end

    def marshal_load(env)
      @env = env
    end

    # Expand the env with more properties, without overriding existing ones.
    # Useful for applying request params after restoring a marshalled Response.
    def apply_request(request_env)
      raise "response didn't finish yet" unless finished?
      @env = request_env.merge @env
      return self
    end
  end
end

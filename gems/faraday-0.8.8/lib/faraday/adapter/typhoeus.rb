#---
# Excerpted from "Metaprogramming Ruby 2",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/ppmetr2 for more book information.
#---
module Faraday
  class Adapter
    class Typhoeus < Faraday::Adapter
      self.supports_parallel = true

      def self.setup_parallel_manager(options = {})
        options.empty? ? ::Typhoeus::Hydra.hydra : ::Typhoeus::Hydra.new(options)
      end

      dependency 'typhoeus'

      def call(env)
        super
        perform_request env
        @app.call env
      end

      def perform_request(env)
        read_body env

        hydra = env[:parallel_manager] || self.class.setup_parallel_manager
        hydra.queue request(env)
        hydra.run unless parallel?(env)
      rescue Errno::ECONNREFUSED
        raise Error::ConnectionFailed, $!
      end

      # TODO: support streaming requests
      def read_body(env)
        env[:body] = env[:body].read if env[:body].respond_to? :read
      end

      def request(env)
        method = env[:method]
        # For some reason, prevents Typhoeus from using "100-continue".
        # We want this because Webrick 1.3.1 can't seem to handle it w/ PUT.
        method = method.to_s.upcase if method == :put

        req = ::Typhoeus::Request.new env[:url].to_s,
          :method  => method,
          :body    => env[:body],
          :headers => env[:request_headers],
          :disable_ssl_peer_verification => (env[:ssl] && !env[:ssl].fetch(:verify, true))

        configure_ssl     req, env
        configure_proxy   req, env
        configure_timeout req, env

        req.on_complete do |resp|
          if resp.timed_out?
            if parallel?(env)
              # TODO: error callback in async mode
            else
              raise Faraday::Error::TimeoutError, "request timed out"
            end
          end

          case resp.curl_return_code
          when 0
            # everything OK
          when 7
            raise Error::ConnectionFailed, resp.curl_error_message
          else
            raise Error::ClientError, resp.curl_error_message
          end

          save_response(env, resp.code, resp.body) do |response_headers|
            response_headers.parse resp.headers
          end
          # in async mode, :response is initialized at this point
          env[:response].finish(env) if parallel?(env)
        end

        req
      end

      def configure_ssl(req, env)
        ssl = env[:ssl]

        req.ssl_version = ssl[:version]          if ssl[:version]
        req.ssl_cert    = ssl[:client_cert_file] if ssl[:client_cert_file]
        req.ssl_key     = ssl[:client_key_file]  if ssl[:client_key_file]
        req.ssl_cacert  = ssl[:ca_file]          if ssl[:ca_file]
        req.ssl_capath  = ssl[:ca_path]          if ssl[:ca_path]
      end

      def configure_proxy(req, env)
        proxy = request_options(env)[:proxy]
        return unless proxy

        req.proxy = "#{proxy[:uri].host}:#{proxy[:uri].port}"

        if proxy[:user] && proxy[:password]
          req.proxy_username = proxy[:user]
          req.proxy_password = proxy[:password]
        end
      end

      def configure_timeout(req, env)
        env_req = request_options(env)
        req.timeout = req.connect_timeout = (env_req[:timeout] * 1000) if env_req[:timeout]
        req.connect_timeout = (env_req[:open_timeout] * 1000)          if env_req[:open_timeout]
      end

      def request_options(env)
        env[:request]
      end

      def parallel?(env)
        !!env[:parallel_manager]
      end
    end
  end
end

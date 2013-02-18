require 'action_dispatch'

module OverseerApi
  class Middleware
    def self.default_ignore_exceptions
      [].tap do |exceptions|
        exceptions << ActiveRecord::RecordNotFound if defined? ActiveRecord
        exceptions << AbstractController::ActionNotFound if defined? AbstractController
        exceptions << ActionController::RoutingError if defined? ActionController
      end
    end

    def initialize(app, options = {})
      @app, @options = app, options
      @options[:ignore_exceptions] ||= self.class.default_ignore_exceptions
    end

    def call(env)
      @app.call(env)
    rescue Exception => exception
      options = (env['overseer_rails.options'] ||= {})
      options.reverse_merge!(@options)

      unless Array.wrap(options[:ignore_exceptions]).include?(exception.class)
        OverseerApi.error(exception)
      end

      raise exception
    end
  end
end
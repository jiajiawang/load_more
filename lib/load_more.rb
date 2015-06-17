require 'active_record' unless defined? ActiveRecord

module LoadMore
  def self.configure(&block)
    yield @config ||= LoadMore::Configuration.new
  end

  def self.config
    @config
  end

  class Configuration
    include ActiveSupport::Configurable

    config_accessor :load_limit
    config_accessor :sort_column
    config_accessor :sort_method
  end

  module ActiveRecord
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def load_limit=(limit)
        @@load_limit = limit
      end

      def load_limit
        defined?(@@load_limit) ? @@load_limit : LoadMore.config.load_limit
      end

      def sort_column=(col)
        @@sort_column = col
      end

      def sort_column
        defined?(@@sort_column) ? @@sort_column : LoadMore.config.sort_column
      end

      def sort_method=(method)
        @@sort_method = method
      end

      def sort_method
        defined?(@@sort_method) ? @@sort_method : LoadMore.config.sort_method
      end

      def load_more(options = {})
        load_limit = options.delete(:load_limit) || self.load_limit
        sort_column = options.delete(:sort_column) || self.sort_column
        sort_method = options.delete(:sort_method) || self.sort_method
        last_load_id = options.delete(:last_load)
        rel = order(sort_column => sort_method).limit(load_limit)
        if last_load_id
          where_query = if sort_method == :desc
                          "#{self.table_name}.#{sort_column} < ?"
                        else
                          "#{self.table_name}.#{sort_column} > ?"
                        end
          rel = rel.where(where_query, last_load_id)
        end
        rel
      end

      def last_load(id = nil)
        load_more(last_load: id)
      end
    end
  end
end

LoadMore.configure do |config|
  config.load_limit = 10
  config.sort_column = :id
  config.sort_method = :desc
end

ActiveRecord::Base.send :include, LoadMore::ActiveRecord

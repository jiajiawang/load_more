require 'active_record' unless defined? ActiveRecord

module LoadMore
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      @@load_limit = 10
      @@sort_column = :id
      @@sort_method = :desc

      def load_limit=(limit)
        @@load_limit = limit
      end

      def load_limit
        @@load_limit
      end

      def sort_column=(col)
        @@sort_column = col
      end

      def sort_column
        @@sort_column
      end

      def sort_method=(method)
        @@sort_method = method
      end

      def sort_method
        @@sort_method
      end

      def load_more(options = {})
        load_limit = options.delete(:load_limit) || self.load_limit
        sort_column = options.delete(:sort_column) || self.sort_column
        sort_method = options.delete(:sort_method) || self.sort_method
        last_load_id = options.delete(:last_load)
        rel = order(sort_column => sort_method).limit(load_limit)
        if last_load_id
          where_query = if sort_method == :desc
                          "#{self.table_name}.id < ?"
                        else
                          "#{self.table_name}.id > ?"
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

ActiveRecord::Base.send :include, LoadMore::ActiveRecord

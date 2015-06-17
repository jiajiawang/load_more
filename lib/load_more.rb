require 'active_record' unless defined? ActiveRecord

module LoadMore
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      @@load_limit = 10

      def load_limit=(limit)
        @@load_limit = limit
      end

      def load_limit
        @@load_limit
      end

      def load_more(options = {})
        load_limit = options.delete(:load_limit) || self.load_limit
        last_load_id = options.delete(:last_load)
        rel = order(id: :desc).limit(load_limit)
        rel = rel.where("#{self.table_name}.id < ?", last_load_id) if last_load_id
        rel
      end

      def last_load(id = nil)
        load_more(last_load: id)
      end
    end
  end
end

ActiveRecord::Base.send :include, LoadMore::ActiveRecord

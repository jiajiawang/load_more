require 'active_record' unless defined? ActiveRecord

module LoadMore
  module ActiveRecord
    @@per_load = 10

    def per_load=(limit)
      @@per_load = limit
    end

    def per_load
      @@per_load
    end

    def load_more(options = {})
      per_load = options.delete(:per_load) || self.per_load
      last_load_id = options.delete(:last_load)
      rel = order(id: :desc).limit(per_load)
      rel = rel.where('id < ?', last_load_id) if last_load_id
      rel
    end

    def last_load(id)
      load_more(last_load: id)
    end
  end

  module ActsAsLoadMore
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_load_more
        extend LoadMore::ActiveRecord
      end
    end
  end
end

ActiveRecord::Base.send :include, LoadMore::ActsAsLoadMore

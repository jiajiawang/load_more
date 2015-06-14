require 'active_record' unless defined? ActiveRecord

module LoadMore
  module ActsAsLoadMore
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_load_more
        scope :load_more, -> { order(id: :desc).limit(10) }
        scope :last_load, ->(id) { where("id < ?", id) }
      end
    end
  end
end

ActiveRecord::Base.send :include, LoadMore::ActsAsLoadMore

require 'spec_helper'

def setup
  ActiveRecord::Base.establish_connection :adapter => 'sqlite3', database: ':memory:'
  ActiveRecord::Base.connection.execute "CREATE TABLE Articles (id INTEGER NOT NULL PRIMARY KEY, updated_at DATETIME DEFAULT CURRENT_TIMESTAMP)"
end



RSpec.describe 'LoadMore::ActsAsLoadMore' do
  setup

  before :each do
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.execute "DELETE FROM #{table}"
    end
  end

  class Article < ActiveRecord::Base
    acts_as_load_more
  end

  describe Article do
    subject { Article }
    it { should respond_to?(:load_more) }
    it { should respond_to?(:per_load) }

    describe '#load_more' do
      before :each do
        1.upto(20) do |num|
          Article.create(id: num)
        end
      end

      it 'returns 10 results' do
        expect(Article.load_more.size).to eq(10)
      end

      it 'returns results ordered by id descendingly' do
        expect(Article.load_more.pluck(:id)).to eq((11..20).to_a.reverse)
      end
    end

    describe '#last_load' do
      it 'returns only results whose id is less than the given id' do
        1.upto(5) do |num|
          Article.create(id: num)
        end
        expect(Article.last_load(4).pluck(:id)).to eq((1..3).to_a)
      end
    end
  end
end

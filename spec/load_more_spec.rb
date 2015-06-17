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

  class Article < ActiveRecord::Base; end

  describe Article do
    it 'its default load_limit is 10' do
      expect(Article.load_limit).to eq(10)
    end

    describe "load_limit=" do
      it 'assigns load_limit to the given argument' do
        Article.load_limit = 15
        expect(Article.load_limit).to eq(15)
      end
    end

    describe '#load_more' do
      before :each do
        Article.load_limit = 8
        1.upto(20) do |num|
          Article.create(id: num)
        end
      end

      it 'returns results ordered by id descendingly' do
        expect(Article.load_more.pluck(:id)).to eq((13..20).to_a.reverse)
      end

      it 'returns {Article.load_limit} results if no per_load specified' do
        expect(Article.load_more.size).to eq(Article.load_limit)
      end

      it 'returns the specified number of results if load_limit is specified' do
        expect(Article.load_more(load_limit: 9).size).to eq(9)
      end

      it 'retunrs the most recent results if last_load is nil' do
        expect(Article.load_more(load_limit: nil).pluck(:id)).to match_array((13..20).to_a)
      end

      it 'retunrs the most recent results if last_load is not specified' do
        expect(Article.load_more(load_limit: nil).pluck(:id)).to match_array((13..20).to_a)
      end

      it 'returns only results whose is less than last_load if it is specified' do
        expect(
          Article.load_more(last_load: 15).map(&:id)
        ).to match_array((7..14).to_a)
      end
    end

    describe '#last_load' do
      context 'with argument' do
        it 'calls load_more with option last_load: argment' do
          id = 10
          expect(Article).to receive(:load_more).with({last_load: id})
          Article.last_load(id)
        end
      end
      context 'without argument' do
        it 'calls load_more with option last_load: nil' do
          expect(Article).to receive(:load_more).with({last_load: nil})
          Article.last_load
        end
      end
    end
  end
end

require 'spec_helper'

def setup
  ActiveRecord::Base.establish_connection :adapter => 'sqlite3', database: ':memory:'
  ActiveRecord::Base.connection.execute "CREATE TABLE Articles (id INTEGER NOT NULL PRIMARY KEY, another_id INTEGER UNIQUE, updated_at DATETIME DEFAULT CURRENT_TIMESTAMP)"
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
    it 'has default load_limit value 10' do
      expect(Article.load_limit).to eq(10)
    end

    it 'has default sort_column value :id' do
      expect(Article.sort_column).to eq(:id)
    end

    it 'has default sort_method value :desc' do
      expect(Article.sort_method).to eq(:desc)
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
          Article.create(id: num, another_id: 121 - num)
        end
      end

      it 'returns results ordered by id descendingly by default' do
        expect(Article.load_more.map(&:id)).to eq((13..20).to_a.reverse)
      end

      it 'returns results ordered by id ascendingly if sort_method is specified as :asc' do
        expect(Article.load_more(sort_method: :asc).map(&:id)).to eq((1..8).to_a)
      end

      it 'returns results ordered by the specified sort_column if sort_column option is specified' do
        expect(Article.load_more(sort_column: :another_id).map(&:another_id)).to eq((113..120).to_a.reverse)
      end

      it 'returns {Article.load_limit} results if no load_limit specified' do
        expect(Article.load_more.size).to eq(Article.load_limit)
      end

      it 'returns the specified number of results if load_limit is specified' do
        expect(Article.load_more(load_limit: 9).size).to eq(9)
      end

      it 'retunrs the most recent results if last_load is nil' do
        expect(Article.load_more(load_limit: nil).pluck(:id)).to match_array((13..20).to_a)
      end

      it 'retunrs the most recent results if last_load is not specified' do
        expect(Article.load_more().pluck(:id)).to match_array((13..20).to_a)
      end

      it 'returns only results whose sort_column is less than last_load if last_load is specified and sort_method is :desc' do
        expect(
          Article.load_more(sort_column: :id, sort_method: :desc, last_load: 15).map(&:id)
        ).to match_array((7..14).to_a)
      end

      it 'returns only results whose is large than last_load if last_load is specified and sort_method is :asc' do
        expect(
          Article.load_more(sort_column: :another_id, sort_method: :asc, last_load: 110).map(&:another_id)
        ).to match_array((111..118).to_a)
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

# frozen_string_literal: true

require 'csv'
require 'sinatra'
require 'sinatra/reloader'

MEMO_FILE_NAME = 'memos.csv'

Memo = Data.define(:id, :title, :content)

get '/memos' do
  @title = 'memo list'
  @memos = []
  CSV.foreach(MEMO_FILE_NAME) do |id, title, content|
    @memos << Memo.new(id.to_i, title, content)
  end
  erb :index
end

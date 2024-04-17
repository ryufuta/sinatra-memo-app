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

get '/memos/:id' do |memo_id|
  memo_id = memo_id.to_i
  raise Sinatra::NotFound if memo_id.zero?

  @title = 'show memo'
  @memo = nil
  CSV.foreach(MEMO_FILE_NAME) do |id, title, content|
    id = id.to_i
    if id == memo_id
      @memo = Memo.new(id, title, content)
      break
    end
  end

  raise Sinatra::NotFound if @memo.nil?

  erb :show
end

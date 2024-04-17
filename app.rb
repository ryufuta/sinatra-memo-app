# frozen_string_literal: true

require 'csv'
require 'sinatra'
require 'sinatra/reloader'

MEMO_FILE_NAME = 'memos.csv'

Memo = Data.define(:id, :title, :content)

def load_memos
  memos = []
  CSV.foreach(MEMO_FILE_NAME) do |id, title, content|
    memos << Memo.new(id.to_i, title, content)
  end
  memos
end

memos = load_memos

get '/memos' do
  @title = 'memo list'
  @memos = memos
  erb :index
end

get '/memos/:id' do |memo_id|
  memo_id = memo_id.to_i
  raise Sinatra::NotFound if memo_id.zero?

  @title = 'show memo'
  @memo = memos.find { |memo| memo.id == memo_id }
  raise Sinatra::NotFound if @memo.nil?

  erb :show
end

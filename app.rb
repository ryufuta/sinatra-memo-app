# frozen_string_literal: true

require 'csv'
require 'securerandom'
require 'sinatra'
require 'sinatra/reloader'

MEMO_FILE_NAME = 'memos.csv'

Memo = Data.define(:id, :title, :content)

def load_memos
  memos = []
  CSV.foreach(MEMO_FILE_NAME) do |id, title, content|
    memos << Memo.new(id, title, content)
  end
  memos
end

def save_memos(memos)
  CSV.open(MEMO_FILE_NAME, 'w') do |csv|
    memos.each { |memo| csv << memo.deconstruct }
  end
end

memos = load_memos

Signal.trap(:INT) { save_memos(memos) }

get '/memos' do
  @title = 'memo list'
  @memos = memos
  erb :index
end

get '/memos/new' do
  @title = 'new memo'
  erb :new
end

post '/memos' do
  memos << Memo.new(SecureRandom.uuid, params[:title], params[:content])
  redirect '/memos'
end

get '/memos/:id' do |memo_id|
  @title = 'show memo'
  @memo = memos.find { |memo| memo.id == memo_id }
  raise Sinatra::NotFound if @memo.nil?

  erb :show
end

delete '/memos/:id' do |memo_id|
  memos = memos.reject { |memo| memo.id == memo_id }
  redirect '/memos'
end

# frozen_string_literal: true

require 'csv'
require 'securerandom'
require 'sinatra'
require 'sinatra/reloader'

MEMO_FILE_NAME = 'memos.csv'

def load_memos
  memos = []
  CSV.foreach(MEMO_FILE_NAME) do |id, title, content|
    memos << { id:, title:, content: }
  end
  memos
end

def save_memos(memos)
  CSV.open(MEMO_FILE_NAME, 'w') do |csv|
    memos.each { |memo| csv << memo.fetch_values(:id, :title, :content) }
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
  memos << { id: SecureRandom.uuid, title: params[:title], content: params[:content] }
  redirect '/memos'
end

get '/memos/:id' do |memo_id|
  @title = 'show memo'
  @memo = memos.find { |memo| memo[:id] == memo_id }
  raise Sinatra::NotFound if @memo.nil?

  erb :show
end

get '/memos/:id/edit' do |memo_id|
  @title = 'edit memo'
  @memo = memos.find { |memo| memo[:id] == memo_id }
  raise Sinatra::NotFound if @memo.nil?

  erb :edit
end

patch '/memos/:id' do |memo_id|
  memo_edited = memos.find { |memo| memo[:id] == memo_id }
  memo_edited[:title] = params[:title]
  memo_edited[:content] = params[:content]
  redirect '/memos'
end

delete '/memos/:id' do |memo_id|
  memos = memos.reject { |memo| memo[:id] == memo_id }
  redirect '/memos'
end

not_found do
  erb :not_found, layout: false
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def hattr(text)
    Rack::Utils.escape_path(text)
  end
end

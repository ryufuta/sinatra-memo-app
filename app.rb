# frozen_string_literal: true

require 'pg'
require 'sinatra'
require 'sinatra/reloader'

DB_NAME = 'memo_app'
USER = 'postgres'
TABLE_NAME = 'memos'

conn = PG.connect(dbname: DB_NAME, user: USER)

get '/memos' do
  @title = 'memo list'
  @memos = conn.exec("SELECT * FROM #{TABLE_NAME}").values.map { |id, title, content| { id:, title:, content: } }
  erb :index
end

get '/memos/new' do
  @title = 'new memo'
  erb :new
end

post '/memos' do
  conn.exec("INSERT INTO #{TABLE_NAME} (title, content) VALUES ('#{params[:title]}', '#{params[:content]}')")
  redirect '/memos'
end

get '/memos/:id' do |memo_id|
  @title = 'show memo'
  @memo = conn.exec("SELECT * FROM #{TABLE_NAME} WHERE id = #{memo_id}").values.map { |id, title, content| { id:, title:, content: } }[0]
  raise Sinatra::NotFound if @memo.nil?

  erb :show
end

get '/memos/:id/edit' do |memo_id|
  @title = 'edit memo'
  @memo = conn.exec("SELECT * FROM #{TABLE_NAME} WHERE id = #{memo_id}").values.map { |id, title, content| { id:, title:, content: } }[0]
  raise Sinatra::NotFound if @memo.nil?

  erb :edit
end

patch '/memos/:id' do |memo_id|
  conn.exec("UPDATE #{TABLE_NAME} SET (title, content) = ('#{params[:title]}', '#{params[:content]}') WHERE id = #{memo_id}")
  redirect '/memos'
end

delete '/memos/:id' do |memo_id|
  conn.exec("DELETE FROM #{TABLE_NAME} WHERE id = #{memo_id}")
  redirect '/memos'
end

not_found do
  erb :not_found, layout: false
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

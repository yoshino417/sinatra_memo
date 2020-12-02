# frozen_string_literal: true

require  'sinatra'
require  'sinatra/reloader'
require 'json'

def read_file
  memos = []
  File.open('data.json') do |file|
    memos = JSON.load(file)
  end
  memos
end

def write_file(memos)
  File.open('data.json', 'w') do |file|
    JSON.dump(memos, file)
  end
end

before do
  @memos = []
  @memos = read_file
end

get '/' do
  @title = 'メモアプリ'
  erb :index
end

get '/add' do
  @title = 'メモ追加'
  erb :add
end

post '/add' do
  @memos << { 'title' => params[:title], 'content' => params[:content] }
  write_file(@memos)
  redirect '/'
end

get '/show/:id' do
  @title = "メモ#{params[:id]}"
  @memo_id = params[:id].to_i
  erb :show
end

get '/edit/:id' do
  @title = 'メモ編集'
  erb :edit
end

patch '/edit/patch/:id' do
  @memos[params[:id].to_i]['title'] = params[:title]
  @memos[params[:id].to_i]['content'] = params[:content]
  write_file(@memos)
  redirect '/'
end

delete '/delete/:id' do
  @memos.delete_at(params[:id].to_i)
  write_file(@memos)
  redirect '/'
end

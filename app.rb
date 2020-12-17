# frozen_string_literal: true

require  'sinatra'
require  'sinatra/reloader'
require  'json'
require  'cgi/escape'

def read_file
  File.open('data.json', 'r') do |file|
    JSON.parse(file.read)
  end
end

def write_file(memos)
  File.open('data.json', 'w') do |file|
    JSON.dump(memos, file)
  end
end

before do
  @memos = read_file
end

get '/' do
  @title = 'メモアプリTop'
  erb :index
end

get '/add' do
  @title = 'メモ追加'
  erb :add
end

post '/add' do
  @memos << { 'title' => CGI.escapeHTML(params[:title]), 'content' => CGI.escapeHTML(params[:content]) }
  write_file(@memos)
  redirect '/'
end

get '/show/:id' do
  @title = "メモ#{params[:id]}"
  @memo_id = params[:id].to_i
  @memos[params[:id].to_i] == {} ? (redirect '/') : (erb :show)
end

get '/edit/:id' do
  @title = 'メモ編集'
  @memos[params[:id].to_i] == {} ? (redirect '/') : (erb :edit)
end

patch '/edit/patch/:id' do
  @memos[params[:id].to_i]['title'] = CGI.escapeHTML(params[:title])
  @memos[params[:id].to_i]['content'] = CGI.escapeHTML(params[:content])
  write_file(@memos)
  redirect '/'
end

delete '/delete/:id' do
  @memos[params[:id].to_i] = {}
  write_file(@memos)
  redirect '/'
end

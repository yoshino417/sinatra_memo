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

def allocate_id(memos)
  memos == [] ? 1 : memos[-1]['id'] + 1
end

def get_index(memos, memo_id)
  memo_index = nil
  memos.each_with_index do |memo, i|
    memo_index = i if memo['id'] == memo_id
  end
  memo_index.nil? ? nil : memo_index
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
  @memos << { 'title' => CGI.escapeHTML(params[:title]), 'content' => CGI.escapeHTML(params[:content]), 'id' => allocate_id(@memos) }
  write_file(@memos)
  redirect '/'
end

get '/show/:id' do
  @title = 'メモ詳細'
  @memo_index = get_index(@memos, params[:id].to_i)
  @memo_index.nil? ? (redirect '/') : (erb :show)
end

get '/edit/:id' do
  @title = 'メモ編集'
  @memo_index = get_index(@memos, params[:id].to_i)
  @memo_index.nil? ? (redirect '/') : (erb :edit)
end

patch '/edit/patch/:id' do
  memo_index = get_index(@memos, params[:id].to_i)
  if memo_index.nil?
    redirect '/'
  else
    @memos[memo_index]['title'] = CGI.escapeHTML(params[:title])
    @memos[memo_index]['content'] = CGI.escapeHTML(params[:content])
    write_file(@memos)
    redirect '/'
  end
end

delete '/delete/:id' do
  @memos.each do |memo|
    @memos.delete(memo) if memo['id'] == params[:id].to_i
  end
  write_file(@memos)
  redirect '/'
end

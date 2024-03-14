#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pg'


def init_db
	@db = PG::Connection.new( dbname: 'leprosorium', port: 5432, password: 'postgres', user: 'postgres', host: 'localhost' )
end

before do
	init_db
end

configure do
	init_db
	@db.exec("
		CREATE TABLE IF NOT EXISTS Posts
		(
    id serial,
    created_date date,
    content text,
    PRIMARY KEY (id)
		);")
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/new' do
	erb :new
end

post '/new' do
	content = params[:content]

	erb "You typed #{content}"
end
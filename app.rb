#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pg'


def init_db
	@db = PG::Connection.new( dbname: 'leprosorium', port: 5432, password: 'postgres', user: 'postgres', host: 'localhost' )
end

#вызывается каждый раз при перезагрузке любой страницы
before do
	# инициализация БД
	init_db
end

# вызывается каждый раз при конфигурации приложения:
# когда изменился код программы и перезагрузилась страница

configure do
	# инициализация БД
	init_db
	@db.exec("
		CREATE TABLE IF NOT EXISTS Posts
		(
    id serial,
    created_date date,
    content text,
    author_name text,
    PRIMARY KEY (id)
		);")

	@db.exec("
		CREATE TABLE IF NOT EXISTS Comments
		(
    id serial,
    created_date date,
    content text,
    post_id integer,
    PRIMARY KEY (id)
		);")
end

get '/' do
	# выбираем список постов из БД

	@result = @db.exec("select * from Posts order by id desc")
	erb :index
end

get '/new' do
	erb :new
end

post '/new' do
	# получаем переменную из post-запроса
	content = params[:content]
	author_name = params[:author_name]

	if content.length < 1 || author_name.length < 1
		@error = 'Введите текст'
		erb :new
	end


	# сохранение данных в БД
	@db.exec("insert into Posts (content, created_date, author_name) values ($1, current_date, $2)", [content, author_name])

	# перенаправление на главную страницу
	redirect to ('/')
	
end

# вывод информации о посте

get '/details/:post_id' do
	# получаем переменную из url'a
	post_id = params[:post_id]

	#получаем список постов
	# (у нас будет только один пост)
	result = @db.exec("select * from Posts where id = ($1)", [post_id])
	# выбираем этот один пост в переменную @row 
	@row = result[0]

	# выбираем комментарий для нашего поста
	@comments = @db.exec("select * from Comments where post_id = ($1) order by id", [post_id])

	erb :details
end

post '/details/:post_id' do
	# получаем переменную из url'a
	post_id = params[:post_id]

	# получаем переменную из post-запроса
	content = params[:content]

	if content.length < 1
		@error = 'Введите текст'
		erb '/details/' + post_id
	end

	#сохранение данных в БД
	@db.exec("insert into Comments (content, created_date, post_id) values ($1, current_date, $2)", [content, post_id])

	# перенаправление на страницу поста
	redirect to ('/details/' + post_id)
end
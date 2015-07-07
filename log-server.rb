require 'thread'
require 'thin'
require 'sinatra'
require 'json'


Thread.new {
	Thin::Server.start('0.0.0.0', 3333, Class.new(Sinatra::Base) {
		                   get '/logs' do
			                   ret = {}
			                   ret[:foo] = 'bar'
			                   ret[:baz] = 'too'
			                   ret.to_json

		                   end

		                   post '/message'
		                    ret = {}
		                   jso = JSON.parse(params[:data], :symbolize_names => true)

		                   ret[:foo] = 'success'

 })}
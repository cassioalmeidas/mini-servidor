require 'socket'
require './servidor_web.rb'

HOST = 'localhost'
PORTA = 2323

servidor = TCPServer.new(HOST, PORTA)

puts "Servidor rodando em http://#{HOST}:#{PORTA}"

loop do 
  socket = servidor.accept
  requisicao = socket.gets

  puts requisicao
  puts Time.now

  Thread.start(socket, requisicao) do |s, r|
    ServidorWeb.new(s, r).servir()
  end
end
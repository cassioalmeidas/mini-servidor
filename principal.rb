require 'socket'
require './servidor_web.rb'

servidor = TCPServer.new('localhost', '2323')

loop do 
  socket = servidor.accept
  requisicao = socket.gets

  STDERR.puts requisicao

  Thread.start(socket, requisicao) do |sessao, requisicao|
    ServidorWeb.new(socket, requisicao).servir()
  end
end
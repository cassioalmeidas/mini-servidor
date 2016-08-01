require 'socket'
require './servidor_web.rb'

servidor = TCPServer.new('localhost', '2323')

loop do 
  socket = servidor.accept
  requisicao = socket.gets

  STDERR.puts requisicao
  STDERR.puts Time.now

  Thread.start(socket, requisicao) do |s, r|
    ServidorWeb.new(s, r).servir()
  end
end
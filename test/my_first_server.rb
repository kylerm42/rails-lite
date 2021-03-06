require 'WEBrick'

server = WEBrick::HTTPServer.new :Port => 8080

server.mount_proc '/' do |req, res|
  res.content_type = 'text/text'
  res.body = req.path

  trap('INT') { server.shutdown }
end

server.start
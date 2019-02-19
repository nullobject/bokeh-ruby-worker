require 'bundler/setup'
require 'ffi-rzmq'
require 'json'
require 'ostruct'

if ARGV.length < 1
  puts 'usage: ruby worker.rb <connect-to>'
  exit
end

connect_to = ARGV[0]

ctx = ZMQ::Context.new
s = ctx.socket(ZMQ::REP)
s.connect(connect_to)

json = ''

while true do
  s.recv_string(json)

  if json.length > 0
    request = OpenStruct.new(JSON.parse(json))
    puts request

    response = OpenStruct.new(id: request.id, response: 'completed', data: request.data.reverse)
    puts response

    json = JSON.dump(response.marshal_dump)
    s.send_string(json, 0)
  end
end

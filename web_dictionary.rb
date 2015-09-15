require "webrick"
require 'json'

class AddWordFromJSON < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    word       = request.query["word"]
    definition = request.query["definition"]

    File.open("dictionary.txt", "a+") do |file|
      file.puts "#{word} = #{definition}"
    end

    response.status = 201
    response["Access-Control-Allow-Origin"] = "*"
    response["Content-Type"] = "application/json"
    response.body = {status: :ok}.to_json
  end
end

class ServeWordsInJSON < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request,response)
    dictionary_lines = File.readlines("dictionary.txt")

    array_of_hashes = dictionary_lines.map do |line|
      word, definition = line.chomp.split(" = ")
      {
        word: word,
        definition: definition
      }
    end

    response.status = 200
    response["Content-Type"] = "application/json"
    response["Access-Control-Alw"] = "*"
    response.body   = array_of_hashes.to_json
  end
end


class SearchWordFromJSON < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)

    lines =File.readlines("dictionary.txt")
    match = lines.select { |line| line.include? (request.query["q"])}
    array_of_match = match.map do |line|
      word, definition = line.chomp.split(" = ")
      {
        word: word,
        definition: definition
      }
    end


    response.status = 200
    response["Access-Control-Allow-Origin"] = "*"
    response["Content-Type"] = "application/json"
    response.body = array_of_match.to_json
  end
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount "/words.json", ServeWordsInJSON
server.mount "/create", AddWordFromJSON
server.mount "/search", SearchWordFromJSON

trap "INT" do server.shutdown end
server.start

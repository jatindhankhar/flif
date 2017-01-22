require 'httparty'

def send_attachments(attachments,chat_id,token)
  puts "Method Called"
  headers = {'content-type' => "application/x-www-form-urlencoded"}
  base_url = "https://api.flock.co/v1/chat.sendMessage/"

  #request_body = attachments.reduce([]) { |arr,el| arr << make_flock_json(el) }
  result = []
  attachments.each do |el|
    query = {
      "to" => chat_id,
      "text" => "",
      "token" => token,
      "attachments" =>  [make_flock_json(el)].to_json
    }
    # Blocking call shift to background workers in next version
    result << HTTParty.post(base_url,:query => query, :headers => headers).parsed_response
  end
  result
end

def make_flock_json gif_url
  body = {"title" => "" , "description" => ""}
  views = {}
  views["image"] = {}
  views["image"]["original"] = {"src" => gif_url,"height" => "400","width" => "400"}
  views["image"]["thumbnail"] = views["image"]["original"]
  body["views"] = views
  body
end


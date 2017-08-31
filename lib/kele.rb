require 'httparty'
require 'json'
require './lib/roadmap.rb'

class Kele
  include HTTParty
  include Roadmap
  base_uri "https://www.bloc.io/api/v1"

  def initialize(email, password)
    response = self.class.post('https://www.bloc.io/api/v1/sessions', body: {"email": email, "password": password})
    raise "Invalid email/password" if response.code != 200
    @auth_token = response["auth_token"]
  end

  def get_me
    response = self.class.get('https://www.bloc.io/api/v1/users/me', headers: { "authorization" => @auth_token })
    JSON.parse response.body
  end

  def get_mentor_availability(mentor_id)
    response = self.class.get("https://www.bloc.io/api/v1/mentors/#{mentor_id}/student_availability", headers: { "authorization" => @auth_token })
    JSON.parse response.body
    # mentor id = 2362517
  end

  def get_messages(id=nil)
    puts "id = "
    puts id
    if id != nil
      response = self.class.get("https://www.bloc.io/api/v1/message_threads?page=1", headers: { "authorization" => @auth_token })
      messages = JSON.parse response.body
      result = messages["items"]
    else
      response = self.class.get("https://www.bloc.io/api/v1/message_threads?page=1", headers: { "authorization" => @auth_token })
      messages = JSON.parse response.body
      total_message_count = messages["count"]
      result = messages["items"]
      count = 1
      total_message_count -= 10
      while total_message_count > 0
        puts "Total Message Count = "
        puts total_message_count
        count += 1
        response = self.class.get("https://www.bloc.io/api/v1/message_threads?page=2", headers: { "authorization" => @auth_token })
        temp_messages = JSON.parse response.body
        result.concat temp_messages["items"]
        total_message_count -= 10
      end
    end
    result.each { |x| puts x }
    puts
  end

  def create_messages(*token)
    response = self.class.post('https://www.bloc.io/api/v1/messages', values: { "sender" => "carissabcastro@gmail.com", "recipient_id" => 2362517, "token" => token, "subject" => "Royale with cheese", "stripped-text" => "That's what they call a quarter pounder in France." }, headers: { "authorization" => @auth_token })
    puts response
  end
end

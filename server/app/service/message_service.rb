# frozen_string_literal: true

require 'messages_services_pb'

class MessageService < Messages::MessageService::Service
  def replicate_message(request, _call)
    timer_s = (5..15).to_a.sample
    # sleep randomly from 1 to 10 seconds to prove that blocking replication requirement from task 1 work
    Rails.logger.info { "secondary randomly sleep for #{timer_s} seconds" }
    sleep(timer_s)
    message_item = { id: request.id, title: request.title }
    existing_message = $messages.detect { |m| m[:id] == request.id }
    if existing_message
      Rails.logger.info { "message $$$#{request.title}$$$ was not replicated because already exists" }
      Messages::Message.new(existing_message)
    else
      $messages << message_item
      Rails.logger.info { "message $$$#{request.title}$$$ was replicated to secondary server" }
      Messages::Message.new(message_item)
    end
  end
end

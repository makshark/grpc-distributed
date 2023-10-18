# frozen_string_literal: true

require 'grpc'
require 'messages_services_pb'

class MessagesController < ApplicationController

  def index
    render json: { data: $messages }
  end
end

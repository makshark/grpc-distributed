# frozen_string_literal: true
require 'grpc'
require 'messages_services_pb'

class MessagesController < ApplicationController
  before_action :handle_item_id, only: :create
  before_action :validate_w, only: :create

  # TODO: in 3 iteration add dynamic instance registration
  REPLICATED_SECONDARIES = %w[grpc-ruby-grpc-server-1:50051 grpc-ruby-grpc-server-2:50051]
  @@messages = []
  @@message_id = 0
  def index
    render json: { data: @@messages }
  end

  # not async example
  # def create
  #   if params[:message].present?
  #     message_item = { id: @@message_id, title: params[:message] }
  #     @@messages << message_item
  #     REPLICATED_SECONDARIES.each do |host|
  #       current_stub = stub(host)
  #       current_stub.replicate_message(Messages::Message.new(message_item)).to_h
  #       Rails.logger.info { "Message was replicated to #{host}" }
  #     end
  #     render json: "message was created and replicated to #{REPLICATED_SECONDARIES.count} secondary servers", status: :created
  #   else
  #     render json: "you have not sent messages params to request, or this value is blank", status: :unprocessable_entity
  #   end
  # end

  def create
    if params[:message].present?
      Rails.logger.info { "Creating message with write concern (w param variable) : #{params[:w]}" }
      message_item = { id: @@message_id, title: params[:message] }
      @@messages << message_item
      replicate_secondaries(message_item)
      # TODO: fix this render
      render json: "message was created and replicated to #{REPLICATED_SECONDARIES.count} secondary servers", status: :created
    else
      render json: "you have not sent messages params to request, or this value is blank", status: :unprocessable_entity
    end
  end

  private

  def replicate_secondaries(message_item)
    # params[:w].to_i - 1 - because on master we ALREADY added the message
    latch = CountDownLatch.new(params[:w].to_i - 1)
    threads = []
    REPLICATED_SECONDARIES.each do |host|
      # spawn a new thread for each url
      threads << Thread.new do
        current_stub = stub(host)
        current_stub.replicate_message(Messages::Message.new(message_item)).to_h
        Rails.logger.info { "Message was replicated to #{host}" }
        latch.countdown!
      end
    end

    latch.wait # Wait until all threads have finished
  end

  def stub(host)
    Messages::MessageService::Stub.new(host, :this_channel_is_insecure)
  rescue GRPC::BadStatus => e
    abort "ERROR: #{e.message}"
  end

  def handle_item_id
    # Comment this if you want to check how message deduplication works
    # (of course it is syntethic example)
    # have look for this case i do not change code for master branch, as it is test example, there is not cases that some
    # message will be duplicated during creating inside master
    @@message_id += 1
  end

  def validate_w
    # TODO: refactor 1,2,3 to dynamic variable in 3 iteration after implementing dynamic server registration
    if params[:w].nil? || [1,2,3].exclude?(params[:w])
      render json: "w params is not valid", status: :unprocessable_entity
    end
  end
end

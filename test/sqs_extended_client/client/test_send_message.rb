# frozen_string_literal: true

require "test_helper"

class SqsExtendedClientSendMessageTest < Minitest::Test
  def setup
    @sqs = Aws::SQS::Client.new(
      region: 'us-east-1',
      endpoint: "http://127.0.0.1:9324"
    )
    @sqs.create_queue(queue_name: 'test')
    @sqs.purge_queue(queue_url: "http://localhost:9324/000000000000/test")

    @s3 = Aws::S3::Client.new(
      region: 'us-east-1',
      endpoint: "http://127.0.0.1:9000",
      access_key_id: 'admin',
      secret_access_key: 'adminpass',
    )
    SqsExtendedClient.configure do |config|
      config.bucket_name = 'test'
      config.s3_client = @s3
    end
  end

  def test_does_not_send_to_s3_if_body_size_is_small
    @sqs.send_message({
      queue_url: "http://localhost:9324/000000000000/test",
      message_body: "test"
    })
    body = @sqs.receive_message({
      queue_url: "http://localhost:9324/000000000000/test",
      max_number_of_messages: 1,
      message_attribute_names: ["All"]
    }).messages.first.body
    assert_equal body, "test"
  end

  def test_send_to_s3_if_body_size_is_big
    @sqs.send_message({
      queue_url: "http://localhost:9324/000000000000/test",
      message_body: "test"*10000000
    })
    body = @sqs.receive_message({
      queue_url: "http://localhost:9324/000000000000/test",
      max_number_of_messages: 1,
      message_attribute_names: ["All"]
    }).messages.first.body
    assert_equal body, "test"*10000000
  end
end

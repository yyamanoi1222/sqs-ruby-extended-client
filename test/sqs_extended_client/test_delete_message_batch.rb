# frozen_string_literal: true

require "test_helper"

class SqsExtendedClientDeleteMessageBatchTest < Minitest::Test
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

  def test_delete_message
    @sqs.send_message({
      queue_url: "http://localhost:9324/000000000000/test",
      message_body: "test"
    })

    handle = @sqs.receive_message({
      queue_url: "http://localhost:9324/000000000000/test",
      max_number_of_messages: 1,
      message_attribute_names: ["All"]
    }).messages.first.receipt_handle

    @sqs.delete_message_batch(
      queue_url: "http://localhost:9324/000000000000/test",
      entries: [
        {
          id: 'test',
          receipt_handle: handle
        }
      ]
    )
  end

  def test_delete_s3_object_if_extended_message
    @sqs.send_message({
      queue_url: "http://localhost:9324/000000000000/test",
      message_body: "test"*10000000
    })

    handle = @sqs.receive_message({
      queue_url: "http://localhost:9324/000000000000/test",
      max_number_of_messages: 1,
      message_attribute_names: ["All"]
    }).messages.first.receipt_handle

    extracted = SqsExtendedClient::ReceiptHandle.extract_receipt_handle(handle)
    @s3.get_object(bucket: extracted.message_body.bucket_name, key: extracted.message_body.key)
    @sqs.delete_message_batch(
      queue_url: "http://localhost:9324/000000000000/test",
      entries: [
        {
          id: 'test',
          receipt_handle: handle
        }
      ]
    )
    result = begin
               @s3.head_object(bucket: extracted.message_body.bucket_name, key: extracted.message_body.key)
             rescue Aws::S3::Errors::NotFound
               nil
             end
    assert_nil result
  end
end

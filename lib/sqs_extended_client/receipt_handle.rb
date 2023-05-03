module SqsExtendedClient
  class ReceiptHandle
    attr_reader :original_receipt_handle, :message_body

    def initialize(original_receipt_handle:, message_body:)
      @original_receipt_handle = original_receipt_handle
      @message_body = message_body
    end

    def embed_extended_info
      [
        original_receipt_handle,
        SqsExtendedClient::Constants::S3_BUCKET_NAME_DELIMITER,
        message_body.bucket_name,
        SqsExtendedClient::Constants::S3_KEY_NAME_DELIMITER,
        message_body.key,
      ].join
    end

    class << self
      def embed_extended_info?(receipt_handle)
        receipt_handle.include?(SqsExtendedClient::Constants::S3_BUCKET_NAME_DELIMITER) &&
          receipt_handle.include?(SqsExtendedClient::Constants::S3_KEY_NAME_DELIMITER)
      end

      def extract_receipt_handle(receipt_handle)
        bucket_start = receipt_handle.index(SqsExtendedClient::Constants::S3_BUCKET_NAME_DELIMITER)
        key_start = receipt_handle.index(SqsExtendedClient::Constants::S3_KEY_NAME_DELIMITER)

        original_receipt_handle = receipt_handle[0..bucket_start-1]
        bucket_name = receipt_handle[(bucket_start + SqsExtendedClient::Constants::S3_BUCKET_NAME_DELIMITER.length)..key_start-1]
        key = receipt_handle[(key_start + SqsExtendedClient::Constants::S3_KEY_NAME_DELIMITER.length)..]

        new(
          original_receipt_handle: original_receipt_handle,
          message_body: SqsExtendedClient::MessageBody.new(
            bucket_name: bucket_name,
            key: key
          )
        )
      end
    end
  end
end

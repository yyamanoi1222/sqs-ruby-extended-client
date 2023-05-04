require 'securerandom'

module SqsExtendedClient
  module Client
    def send_message(params = {}, options = {})
      body = params[:message_body]

      if __need_to_send_to_s3?(body)
        key = __store_orig_body_to_s3(body)
        params[:message_body] = __build_body(key)
        params[:message_attributes] = __add_extended_attribute(body.to_s.size.to_s, params.fetch(:message_attributes, {}))
      end

      super
    end

    def send_message_batch(params = {}, options = {})
      params[:entries] = params[:entries].map do |entry|
        body = entry[:message_body]
        if __need_to_send_to_s3?(body)
          key = __store_orig_body_to_s3(body)
          entry[:message_body] = __build_body(key)
          entry[:message_attributes] = __add_extended_attribute(body.to_s.size.to_s, entry.fetch(:message_attributes, {}))
        end
        entry
      end

      super
    end

    def receive_message(params = {}, options = {})
      resp = super
      resp.messages.map! do |message|
        next message unless __has_extended_attribute?(message)

        message_body = __extract_message_body(message.body)
        orig_body = __restore_orig_body_from_s3(message_body)
        message.receipt_handle = __embed_receipt_handle(message.receipt_handle, message_body)
        message.body = orig_body
        message
      end
      resp
    end

    def delete_message(params = {}, options = {})
      if __embed_receipt_handle?(params[:receipt_handle])
        extracted_receipt_handle = __extract_original_receipt_handle(params[:receipt_handle])
        params[:receipt_handle] = extracted_receipt_handle.original_receipt_handle

        __delete_body_from_s3(extracted_receipt_handle.message_body)
      end

      super
    end

    def delete_message_batch(params = {}, options = {})
      params[:entries] = params[:entries].map do |entry|
        if __embed_receipt_handle?(entry[:receipt_handle])
          extracted_receipt_handle = __extract_original_receipt_handle(entry[:receipt_handle])
          entry[:receipt_handle] = extracted_receipt_handle.original_receipt_handle

          __delete_body_from_s3(extracted_receipt_handle.message_body)
        end
        entry
      end

      super
    end

    private

    def __store_orig_body_to_s3(body)
      key = SecureRandom.uuid
      __extended_client_configuration.s3_client.put_object({
        bucket: __extended_client_configuration.bucket_name,
        key: key,
        body: body,
      })
      key
    end

    def __restore_orig_body_from_s3(message_body)
      __extended_client_configuration.s3_client.get_object({
        bucket: message_body.bucket_name,
        key: message_body.key,
      }).body.read
    end

    def __delete_body_from_s3(message_body)
      __extended_client_configuration.s3_client.delete_object({
        bucket: message_body.bucket_name,
        key: message_body.key,
      })
    end

    def __extract_message_body(body)
      SqsExtendedClient::MessageBody.parse_from_json(body)
    end

    def __embed_receipt_handle(receipt_handle, message_body)
      SqsExtendedClient::ReceiptHandle.new(
        original_receipt_handle: receipt_handle,
        message_body: message_body
      ).embed_extended_info
    end

    def __embed_receipt_handle?(receipt_handle)
      SqsExtendedClient::ReceiptHandle.embed_extended_info?(receipt_handle)
    end

    def __extract_original_receipt_handle(receipt_handle)
      SqsExtendedClient::ReceiptHandle.extract_receipt_handle(receipt_handle)
    end

    def __build_body(key)
      SqsExtendedClient::MessageBody.new(
        bucket_name: __extended_client_configuration.bucket_name,
        key: key
      ).to_json
    end

    def __need_to_send_to_s3?(body)
      __extended_client_configuration.always_through || __large?(body)
    end

    def __large?(body)
      body.to_s.size > __extended_client_configuration.threshhold
    end

    def __add_extended_attribute(size, attributes)
      attributes.merge({
        SqsExtendedClient::Constants::ATTRIBUTE_NAME => {
          string_value: size,
          data_type: "Number",
        }
      })
    end

    def __has_extended_attribute?(message)
      message.message_attributes.key?(SqsExtendedClient::Constants::ATTRIBUTE_NAME)
    end

    def __extended_client_configuration
      SqsExtendedClient.configuration
    end
  end
end

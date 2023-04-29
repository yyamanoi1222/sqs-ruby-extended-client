require 'aws-sdk-s3'
require 'securerandom'

module SqsExtendedClient
  module Client
    def send_message(params = {}, options = {})
      body = params[:message_body]

      if _extended_client_configuration.always_through || _large?(body)
        key = SecureRandom.uuid
        _extended_client_configuration.s3_client.put_object({
          bucket: _extended_client_configuration.bucket_name,
          key: key,
          body: body,
        })
        params[:body] = key
      end

      super
    end

    def send_message_batch(params = {}, options = {})
      params[:entries] = params[:entries].map do |entry|
        if _extended_client_configuration.always_through || _large?
          key = SecureRandom.uuid
          _extended_client_configuration.s3_client.put_object({
            bucket: _extended_client_configuration.bucket_name,
            key: key,
            body: body,
          })
          entry[:message_body] = key
        end
        entry
      end

      super
    end

    def receive_message(params = {}, options = {})
      resp = super
      resp.messages.map! do |message|
        body = _extended_client_configuration.s3_client.get_object({
          bucket: _extended_client_configuration.bucket_name,
          key: message.body,
        })
        message.body = body
        message
      end
      resp
    end

    def delete_message(params = {}, options = {})
      super
    end

    private

    def _large?(body)
      true
    end

    def _extended_client_configuration
      SqsExtendedClient.configuration
    end
  end
end

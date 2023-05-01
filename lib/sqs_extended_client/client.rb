require 'securerandom'

module SqsExtendedClient
  module Client
    def send_message(params = {}, options = {})
      body = params[:message_body]

      if __need_to_send_to_s3?(body)
        key = SecureRandom.uuid
        __extended_client_configuration.s3_client.put_object({
          bucket: __extended_client_configuration.bucket_name,
          key: key,
          body: body,
        })
        params[:body] = key
      end

      super
    end

    def send_message_batch(params = {}, options = {})
      params[:entries] = params[:entries].map do |entry|
        if __need_to_send_to_s3?(entry[:body])
          key = SecureRandom.uuid
          __extended_client_configuration.s3_client.put_object({
            bucket: __extended_client_configuration.bucket_name,
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
        body = __extended_client_configuration.s3_client.get_object({
          bucket: __extended_client_configuration.bucket_name,
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

    def __need_to_send_to_s3?(body)
      __extended_client_configuration.always_through || __large?(body)
    end

    def __large?(body)
      body.to_s.size > __extended_client_configuration.threshhold
    end

    def __extended_client_configuration
      SqsExtendedClient.configuration
    end
  end
end

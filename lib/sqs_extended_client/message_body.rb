module SqsExtendedClient
  class MessageBody
    attr_reader :bucket_name, :key

    def self.parse_from_json(body)
      parsed = JSON.parse(body)
      new(bucket_name: parsed['bucket_name'], key: parsed['key'])
    end

    def initialize(bucket_name:, key:)
      @bucket_name = bucket_name
      @key         = key
    end

    def to_json
      {
        bucket_name: bucket_name,
        key: key
      }.to_json
    end
  end
end

module SqsExtendedClient
  class Configuration
    attr_accessor :bucket_name,
                  :s3_client,
                  :always_through,
                  :threshhold

    def initialize
      @always_through = false
      @threshhold = 1024 * 256
      @s3_client = ::Aws::S3::Client.new
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end
end

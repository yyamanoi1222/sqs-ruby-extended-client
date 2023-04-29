module SqsExtendedClient
  class Configuration
    attr_accessor :bucket_name,
                  :always_through

    def initialize
      @always_through = false
    end

    def s3_client
      @s3_client ||= ::Aws::S3::Client.new
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end
end

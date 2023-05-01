require 'aws-sdk-s3'
require 'aws-sdk-sqs'
require 'sqs_extended_client/client'
require 'sqs_extended_client/configuration'

module SqsExtendedClient; end

Aws::SQS::Client.prepend SqsExtendedClient::Client

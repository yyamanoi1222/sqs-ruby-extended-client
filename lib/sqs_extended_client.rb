require 'aws-sdk-s3'
require 'aws-sdk-sqs'
require 'sqs_extended_client/client'
require 'sqs_extended_client/configuration'
require 'sqs_extended_client/constants'
require 'sqs_extended_client/message_body'
require 'sqs_extended_client/receipt_handle'

module SqsExtendedClient; end

Aws::SQS::Client.prepend SqsExtendedClient::Client

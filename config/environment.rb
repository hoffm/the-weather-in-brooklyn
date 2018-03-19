require "aws-sdk-polly"
require "aws-sdk-s3"
require "dotenv"
require "faraday"
require "json"
require "nokogiri"

Dotenv.load

TWIB_APP_PATH = Dir.pwd + "/lib/twib"
Dir["#{TWIB_APP_PATH}/**/*.rb"].each { |file| require file }

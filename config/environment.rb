require "active_support/time"
require "aws-sdk-polly"
require "aws-sdk-s3"
require "dotenv"
require "faraday"
require "fileutils"
require "json"
require "nokogiri"

Dotenv.load('.env', '/etc/secrets/.render_env')

TWIB_APP_PATH = Dir.pwd + "/lib/twib"
require TWIB_APP_PATH + "/constants.rb"
Dir["#{TWIB_APP_PATH}/**/*.rb"].each { |file| require file }
FileUtils.mkdir_p(Twib::JSON_DIR)
FileUtils.mkdir_p(Twib::RSS_DIR)

Time.zone = "America/New_York"

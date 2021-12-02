require "active_support/time"
require "aws-sdk-polly"
require "aws-sdk-s3"
require "dotenv"
require "faraday"
require "fileutils"
require "json"
require "nokogiri"

Dotenv.load(
  '.env', #local
  '/etc/secrets/.render_env' # prod (Render)
)

TWIB_APP_PATH = Dir.pwd + "/lib/twib"
require TWIB_APP_PATH + "/constants.rb"
Dir["#{TWIB_APP_PATH}/**/*.rb"].each { |file| require file }

Time.zone = "America/New_York"

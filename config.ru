# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run FApp::Application

FApp::Application.config.middleware.use ExceptionNotifier,
  :email => {
    :email_prefix => "[Error] ",
    :sender_address => %{<team@fitsby.com>},
    :exception_recipients => %w{daniel@fitsby.com}
  }
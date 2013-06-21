CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: "AWS",
    aws_access_key_id: "AKIAJQR7T44WRW3CA4OA",
    aws_secret_access_key: "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"
  }
  config.fog_directory = "Fitsby-images"


end
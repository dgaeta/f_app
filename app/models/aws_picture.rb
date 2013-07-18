class AwsPicture < AWS::Record::Base
    string_attr :name
     has_attached_file :photo,
                    :styles => { :medium => "300x300>",
                                 :thumb => "100x100>" },
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :path => ":attachment/:id/:style.:extension",
                    :bucket => 'images.fitsby.com'

  end
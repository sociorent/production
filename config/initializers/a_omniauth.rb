case ENV['RAILS_ENV']
  when "development"
    ENV['FACEBOOK_KEY'] = '424914297573197'
    ENV['FACEBOOK_SECRET'] = 'ade69b767d7a9186932852cd9ad22932'
  when "staging"
    ENV['FACEBOOK_KEY'] = '212611612202812'
    ENV['FACEBOOK_SECRET'] = '990066123e92d9624e644740903a6d69'
  when "production"  
    ENV['FACEBOOK_KEY'] = '212611612202812'
    ENV['FACEBOOK_SECRET'] = '990066123e92d9624e644740903a6d69'
end
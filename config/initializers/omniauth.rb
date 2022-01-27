Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, Rails.application.credentials.twitter[:key], Rails.application.credentials.twitter[:secret],
    {
      :secure_image_url => 'true',
      :image_size => 'original',
      :authorize_params => {
        :force_login => 'false',
        :lang => 'en'
      }
    }
end
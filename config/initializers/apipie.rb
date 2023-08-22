# frozen_string_literal: true

Apipie.configure do |config|
  config.app_name                = 'femida persons api'
  config.api_base_url            = '/api/persons'
  config.doc_base_url            = '/api/persons/docs'
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"

  config.languages = ['ru', 'en']
  config.default_locale = 'ru'
  config.authenticate = Proc.new do
    redirect_to '/' unless current_user
  end
end

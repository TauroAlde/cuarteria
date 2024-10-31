class FetchVerifyTokenLifeJob < ApplicationJob
  queue_as :default

  def perform(user_setting_id)
    Rails.logger.info("Fetching and verifying token life for user setting ID: #{user_setting_id}")
    user_setting = Setting.find(user_setting_id)

    if verify_token_life?(user_setting)
      user_setting.token
    else
      update_token(user_setting)
    end
  end

  private

  def verify_token_life?(user_setting)
    VerifyTokenLifeService.new(user_setting.api_key, user_setting.secret_key, user_setting.token).call
  end

  def update_token(user_setting)
    token_generator = TokenGeneratorService.new(user_setting.api_key, user_setting.secret_key)
    user_setting.update(token: token_generator.call.split.last)
  end
end

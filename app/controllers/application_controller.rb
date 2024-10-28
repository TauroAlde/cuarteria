  class ApplicationController < ActionController::Base

  before_action do
    I18n.locale = :es # Or whatever logic you use to choose.
  end
end

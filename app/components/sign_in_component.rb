# frozen_string_literal: true

class SignInComponent < ViewComponent::Base
  def initialize(title: nil)
    @title = title
  end
end

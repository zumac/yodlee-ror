class PagesController < ApplicationController

  def index
    if user_signed_in?
      redirect_to redirect_according_to_role
    end
  end

  def about

  end

  def faq

  end

  def terms_and_conditions

  end

  def privacy_policy

  end
end
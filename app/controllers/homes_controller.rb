class HomesController < ApplicationController
  def api_docs
  end

  def index
    if params[:address]
      require 'mastercoin'
      @result = Mastercoin::BuyingAddress.from_address(params[:address]) 
    end
  end
end

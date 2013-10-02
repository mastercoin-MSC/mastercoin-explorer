class AdvisorsController < ApplicationController
  def create
    @advisor = Advisor.new(params[:advisor])
    if @advisor.valid? && @advisor.advice!
      render :create
    else
      render :new
    end
  end

  def new
    @advisor = Advisor.new
  end
end

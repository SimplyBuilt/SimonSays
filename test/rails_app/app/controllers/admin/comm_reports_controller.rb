class Admin::CommReportsController < ApplicationController
  find_and_authorize :report, :comms, with: :admin, namespace: :admin

  respond_to :json

  def show
    respond_with @report
  end
end

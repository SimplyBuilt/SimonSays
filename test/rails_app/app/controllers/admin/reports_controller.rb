class Admin::ReportsController < ApplicationController
  respond_to :json

  self.default_authorization_scope = :current_admin

  authorize :support
  find_resource :report, namespace: :admin, except: [:index, :new, :create]

  def index
    @reports = Admin::Report.all

    respond_with @reports
  end

  def create
    @report = Admin::Report.create(report_params)

    respond_with @report
  end

  def show
    respond_with @report
  end

  def update
    @report.update report_params

    respond_with @report
  end

  def destroy
    @report.destroy

    respond_with @report
  end

  protected

  def report_params
    params.require(:report).permit(:title)
  end
end

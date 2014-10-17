class DocumentsController < ApplicationController
  respond_to :json

  authenticate :user

  find_and_authorize :document, through: :memberships, only: :show # any role
  find_and_authorize :document, :edit, through: :memberships, only: [:edit, :update]
  find_and_authorize :document, :delete, through: :memberships, only: :destroy
  find_and_authorize :document, :download, through: :memberships, only: :send_file

  def index
    @documents = Document.all

    respond_with @documents
  end

  def create
    @document = Document.create(document_params)

    respond_with @document
  end

  def show
    respond_with @document
  end

  def update
    @document.update document_params

    respond_with @document
  end

  def destroy
    @document.destroy

    respond_with @document
  end

  def send_file
    send_data @document.title, filename: 'doc.txt'
  end

  protected

  def document_params
    params.require(:document).permit(:title)
  end
end

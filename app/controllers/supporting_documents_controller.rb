class SupportingDocumentsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_supporting_document, only: [:show]


  def show
    # @supporting_document is already set by the before_action
  end


  def set_supporting_document
    @supporting_document = SupportingDocument.find(params[:id])
  end

  def index
    @supporting_documents = SupportingDocument.all
  end

  def new
    @supporting_document = SupportingDocument.new
  end



  def create
    @supporting_document = SupportingDocument.new(supporting_document_params.merge(audit_id: Audit.first.id))

    # Attach the uploaded file
    if params[:supporting_document][:file]
      @supporting_document.file.attach(params[:supporting_document][:file])
    end

    if @supporting_document.save
      flash.now[:notice] = "Document uploaded successfully"
      redirect_to supporting_documents_path
    else
      render :new
    end
  end

  private

  def supporting_document_params
    params.require(:supporting_document).permit(:name, :file, :audit_id, :content)
  end
end

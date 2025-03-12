class AddDocumentToDocumentUpdate < ActiveRecord::Migration[7.0]
  def change
    add_reference :document_updates, :document, null: false, foreign_key: true
  end
end

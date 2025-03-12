class CreateSupportingDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :supporting_documents do |t|
      t.string :name
      t.string :content
      t.string :location
      t.datetime :uploaded_at

      t.timestamps
    end
  end
end

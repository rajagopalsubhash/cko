class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.string :number
      t.decimal :amount
      t.string :status
      t.string :due_date
      t.string :reference
      t.string :comments
      t.timestamps
    end
  end
end

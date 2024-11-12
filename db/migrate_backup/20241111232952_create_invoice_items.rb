class CreateInvoiceItems < ActiveRecord::Migration[7.1]
  def change
    create_table :invoice_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.string :item
      t.integer :quantity
      t.float :unit_price

      t.timestamps
    end
  end
end

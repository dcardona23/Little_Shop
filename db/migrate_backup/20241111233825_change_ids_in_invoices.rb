class ChangeIdsInInvoices < ActiveRecord::Migration[7.1]
  def change
    change_column_null :invoices, :customer_id, true
    change_column_null :invoices, :merchant_id, true
  end
end

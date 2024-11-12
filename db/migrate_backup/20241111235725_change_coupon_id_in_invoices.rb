class ChangeCouponIdInInvoices < ActiveRecord::Migration[7.1]
  def change
    remove_column :invoices, :coupon_id, :integer if column_exists?(:invoices, :coupon_id)

    add_reference :invoices, :coupon, foreign_key: true
  end
end

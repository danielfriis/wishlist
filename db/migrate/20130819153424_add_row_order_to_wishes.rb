class AddRowOrderToWishes < ActiveRecord::Migration
  def change
    add_column :wishes, :row_order, :integer
  end
end

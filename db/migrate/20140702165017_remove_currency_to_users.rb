class RemoveCurrencyToUsers < ActiveRecord::Migration
  def up
    remove_column :users, :currency
  end

  def down
    add_column :users, :currency, :string
  end
end

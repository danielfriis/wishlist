class AddPriceCurrencyToItems < ActiveRecord::Migration
  def change
    add_column :items, :price_currency, :string
  end
end

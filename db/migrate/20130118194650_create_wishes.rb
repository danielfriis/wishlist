class CreateWishes < ActiveRecord::Migration
  def change
    create_table :wishes do |t|
      t.integer :list_id
      t.integer :item_id

      t.timestamps
    end
  end
end

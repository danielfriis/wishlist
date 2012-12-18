class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title
      t.string :link
      t.integer :list_id

      t.timestamps
    end
    add_index :items, :list_id
  end
end

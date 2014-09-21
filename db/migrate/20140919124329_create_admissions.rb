class CreateAdmissions < ActiveRecord::Migration
  def change
    create_table :admissions do |t|
      t.belongs_to :user
      t.belongs_to :accessible
      t.string :accessible_type

      t.timestamps
    end
    add_index :admissions, :user_id
    add_index :admissions, :accessible_id
  end
end

class AddNoteToWishes < ActiveRecord::Migration
  def change
    add_column :wishes, :note, :string
  end
end

class AddColumnsToBooks < ActiveRecord::Migration[5.2]
  def change
    add_column :books, :category_id, :string
  end
end

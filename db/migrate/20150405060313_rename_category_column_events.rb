class RenameCategoryColumnEvents < ActiveRecord::Migration
  def change
  	rename_column :events, :category, :category_id
  end
end

class AddPhotoAndTimeColumnEvents < ActiveRecord::Migration
  def change
  	add_column :events, :photo, :string
  	add_column :events, :ampm, :integer
  end
end

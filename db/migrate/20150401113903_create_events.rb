class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.string :description
      t.string :lat
      t.string :lng
      t.string :address
      t.time :etime
      t.date :edate

      t.timestamps null: false
    end
  end
end

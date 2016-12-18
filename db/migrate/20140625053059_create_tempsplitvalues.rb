class CreateTempsplitvalues < ActiveRecord::Migration
  def change
     create_table :Tempsplitvalues do |t|
      t.string :item
    end
  end
end

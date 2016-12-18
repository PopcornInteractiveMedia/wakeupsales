class CreateTempImages < ActiveRecord::Migration
  def change
    create_table :temp_images do |t|
      t.references :user
      t.attachment :avatar

      t.timestamps
    end
    add_index :temp_images, :user_id
  end
end

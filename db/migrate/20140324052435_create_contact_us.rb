class CreateContactUs < ActiveRecord::Migration
  def change
    create_table :contact_us do |t|
      t.string :email
      t.boolean :is_remote, :default => false

      t.timestamps
    end
  end
end

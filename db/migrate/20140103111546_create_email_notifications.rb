class CreateEmailNotifications < ActiveRecord::Migration
  def change
    create_table :email_notifications do |t|
      t.integer :user_id
      t.boolean :due_task
      t.boolean :task_assign
      t.boolean :deal_assign
      t.boolean :donot_send

      t.timestamps
    end
  end
end

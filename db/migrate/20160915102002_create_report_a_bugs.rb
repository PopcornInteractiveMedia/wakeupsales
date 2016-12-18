class CreateReportABugs < ActiveRecord::Migration
  def change
    create_table :report_a_bugs do |t|
      t.string :email
      t.string :bug_type
      t.text :description
      t.string :bug_status, default: "New"

      t.timestamps
    end
  end
end

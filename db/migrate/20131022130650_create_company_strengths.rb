class CreateCompanyStrengths < ActiveRecord::Migration
  def change
    create_table :company_strengths do |t|
      t.string :range

      t.timestamps
    end
  end
end

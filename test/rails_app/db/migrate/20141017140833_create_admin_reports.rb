class CreateAdminReports < ActiveRecord::Migration[5.0]
  def change
    create_table :admin_reports do |t|
      t.string :title

      t.timestamps
    end
  end
end

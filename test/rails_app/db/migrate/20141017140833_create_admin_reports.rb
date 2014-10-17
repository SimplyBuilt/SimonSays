class CreateAdminReports < ActiveRecord::Migration
  def change
    create_table :admin_reports do |t|
      t.references :admin

      t.timestamps
    end
  end
end

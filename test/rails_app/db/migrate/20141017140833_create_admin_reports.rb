class CreateAdminReports < ActiveRecord::Migration
  def change
    create_table :admin_reports do |t|
      t.string :title

      t.timestamps
    end
  end
end

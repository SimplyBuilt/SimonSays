class CreateAdmins < ActiveRecord::Migration[5.0]
  def change
    create_table :admins do |t|
      t.integer   :access_mask

      t.timestamps
    end
  end
end

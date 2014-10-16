class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|
      t.string    :email
      t.integer   :access_mask

      t.timestamps
    end
  end
end

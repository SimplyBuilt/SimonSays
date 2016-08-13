class CreateMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :memberships do |t|
      t.references :user
      t.references :document

      t.integer    :roles_mask, default: 0

      t.timestamps
    end
  end
end

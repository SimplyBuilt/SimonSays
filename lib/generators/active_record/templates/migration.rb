class SimonSaysAddTo<%= table_name.camelize %> < ActiveRecord::Migration<%= migration_version %>
  def change
    add_column :<%= table_name %>, :<%= role_attribute_name %>_mask, :integer, default: 0, null: false
  end
end

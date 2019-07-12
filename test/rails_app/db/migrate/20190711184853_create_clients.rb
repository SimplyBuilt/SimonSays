class CreateClients < ActiveRecord::Migration[5.1]
  def change
    create_table :clients, primary_key: :client_id do |t|
      t.timestamps
    end
  end
end

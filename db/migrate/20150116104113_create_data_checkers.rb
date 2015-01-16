class CreateDataCheckers < ActiveRecord::Migration
  def change
    create_table :data_checkers do |t|

      t.timestamps null: false
    end
  end
end

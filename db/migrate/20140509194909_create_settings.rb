class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings ,:force => true do |t|
      t.string "name"
      t.string "value"
      t.string "kind",  :default => "general"
    end
  end
end

class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.boolean :completed
      t.text :text
      t.bigint :chat_id

      t.timestamps
    end
  end
end

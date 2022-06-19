class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :category
      t.string :summary
      t.string :description

      t.timestamps
    end
  end
end
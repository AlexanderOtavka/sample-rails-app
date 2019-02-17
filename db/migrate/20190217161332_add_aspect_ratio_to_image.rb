class AddAspectRatioToImage < ActiveRecord::Migration[5.1]
  def change
    add_column :images, :aspect_ratio, :float
  end
end

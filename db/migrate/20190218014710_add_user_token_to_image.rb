class AddUserTokenToImage < ActiveRecord::Migration[5.1]
  def change
    add_column :images, :user_token, :string
  end
end

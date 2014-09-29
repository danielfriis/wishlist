class AddOauthInfoToAuthorizations < ActiveRecord::Migration
  def change
    add_column :authorizations, :oauth_token, :string
    add_column :authorizations, :oauth_expires_at, :datetime
  end
end

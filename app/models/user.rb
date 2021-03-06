class User < ApplicationRecord
	has_many :memories

	after_commit :toggle_automated, on: :create

	def self.find_or_create_from_auth_hash(auth_hash)
	  user = where(provider: auth_hash.provider, uid: auth_hash.uid).first_or_create
	  user.update(
	    name: auth_hash.info.nickname,
	    avatar: auth_hash.info.image,
	    token: auth_hash.credentials.token,
	    secret: auth_hash.credentials.secret
	  )
	  user
  end

	## Toggle :automated attribute
	def toggle_automated
		self.automated = true
	end
end
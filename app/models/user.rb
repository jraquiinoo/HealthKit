class User < ActiveRecord::Base
	has_many :events
	def self.create_user(email, username, firstname, lastname, password, photo)
		errors = []
		if User.where(email: email).to_a.length > 0
			errors.push(1)
		end
		if User.where(username: username).to_a.length > 0
			errors.push(2)
		end
		if errors.length == 0

			require 'bcrypt'
			salt = BCrypt::Engine.generate_salt
			hashed_password = BCrypt::Engine.hash_secret(password, salt)
			new_user = User.create(email: email, username: username, firstname: firstname, lastname: lastname,
				password: hashed_password, salt: salt, photo: nil)

			if photo.present?
				directory = "public/data/user/" + new_user.id.to_s()
				filename = photo.original_filename + ".jpg"
				require 'fileutils'
				unless File.directory?(directory)
				  FileUtils.mkdir_p(directory)
				end
			    path = File.join(directory, filename)
			    File.open(path, "w+b") { |f| f.write(photo.read) }
			    User.update(new_user.id, :photo => "data/user/" + new_user.id.to_s() + "/" + filename)
			end
			new_user
		else 
			errors
		end
	end

	def self.authenticate(username, password)
		user = User.where(username: username).first
		if !user.present?
			user = User.where(email: username).first
		end
		require 'bcrypt'
		if user.present? && user.password == BCrypt::Engine.hash_secret(password, user.salt)
			user
		else
			nil
		end
	end
end

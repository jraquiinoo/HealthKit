class AccountController < ApplicationController


	def logout
		session[:user_id] = nil
		redirect_to action: "index", controller: "application"
	end

	def register_get

	end

	def register_post
		result = User.create_user(params[:email], params[:username], 
			params[:first_name], params[:last_name], params[:opassword], params[:photo_file])

		if result.is_a? User
			session[:user_id] = result.id
			render :json => { status: 0 }
		else
			render :json => { status: 1, errors: result}
		end
	end

	def login
		user = User.authenticate(params[:username_login], params[:opassword_login])
		if user.present?
			session[:user_id] = user.id
			render :json => { status: 0 }
		else
			render :json => { status: 1 }
		end
	end

	def change_photo
		User.change_photo(session[:user_id], params[:photo_file])
		redirect_to :back
	end
end

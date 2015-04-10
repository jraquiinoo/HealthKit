class DefaultController < ApplicationController

	def people
		user_id = params[:id]
		user = User.where(id: user_id).first
		if user.present?
			@person = {
				id: user.id,
				firstname: user.firstname,
				lastname: user.lastname,
				username: user.username,
				photo: "http://localhost:3000/data/user/" + user.id.to_s() + "/avatar.jpg"
			}
			render :layout => "application_alternate"
		else
			redirect_to action: "index", controller: "application"
		end
	end

	def edit_event
		user = nil
		if session[:user_id].present?
			user = User.where(id: session[:user_id]).first
		end
		if user.present?
			event_id = params[:ei]
			@categories = []
			Category.all.to_a.each do |category|
				@categories.push({
					id: category.id,
					name: category.name
				})
			end
			if event_id.present?
				event = Event.where(id: event_id).first
				if event.present?
					if event.user_id == session[:user_id]
						@event = {
							id: event.id,
							title: event.title,
							description: event.description,
							photo: "http://localhost:3000/" + event.photo,
							date: event.edate,
							hour: Event.where(id: event.id).pluck("hour(etime)").first.to_i(),
							minute: Event.where(id: event.id).pluck("minute(etime)").first.to_i(),
							lat: event.lat,
							lng: event.lng,
							ampm: event.ampm,
							address: event.address,
							category: event.category.id
						}
						render :layout => "application_alternate"
					else
						redirect_to root_path
					end
				else
					redirect_to root_path
				end
			else
				@event = {
					id: -1,
					lat: -1,
					lng: -1
				}
				render :layout => "application_alternate"
			end
		else
			redirect_to root_path 
		end
	end

	def save_event
		event = nil
		if params[:event_id].to_i() == -1
			event = Event.create_event(session[:user_id], params[:event_title], params[:event_description], 
				params[:event_date], params[:event_time_hour].to_s() + ":" + params[:event_time_minute] + ":00",
				params[:event_address], params[:map_lat], params[:map_lng], params[:event_photo], params[:event_ampm], params[:event_category])	
		else
			event = Event.update_event(session[:user_id], params[:event_id], params[:event_title], params[:event_description], 
				params[:event_date], params[:event_time_hour].to_s() + ":" + params[:event_time_minute] + ":00",
				params[:event_address], params[:map_lat], params[:map_lng], params[:event_photo], params[:event_ampm], params[:event_category])	
		end
		render :json => { status: 0, id: event.id , redirectto: "http://localhost:3000/event/view?ei=" + event.id.to_s()}
	end

	def view_event
		event = nil
		event_id = params[:ei]
		if event_id.present?
			event = Event.where(id: event_id).first
		end
		if event.present?
			user = User.where(id: event.user_id).first
			hour = Event.where(id: event_id).pluck("HOUR(etime)").first.to_s()
			minute = Event.where(id: event_id).pluck("MINUTE(etime)").first.to_s()
			ampm = "AM"
			if minute.to_i() < 10
				minute = "0" + minute
			end
			if hour.to_i() < 10
				hour = "0" + hour
			end
			if event.ampm == 2
				ampm = "PM"
			end
			@event = {
				id: event.id,
				title: event.title,
				description: event.description,
				date: event.edate,
				time: hour + ":" + minute + " " + ampm,
				address: event.address,
				lat: event.lat,
				lng: event.lng,
				category: event.category.name,
				host: {
					id: user.id,
					name: user.firstname + " " + user.lastname,
					username: user.username,
					photo: "http://localhost:3000/" + user.photo
				},
				photo: "http://localhost:3000/" + event.photo
			}
			render  :layout => "application_alternate"
		else 
			redirect_to root_path
		end
	end
end

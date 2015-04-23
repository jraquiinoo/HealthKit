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
				photo: request.protocol + request.host_with_port + "/data/avatar.jpg"
			}
			if user.photo.present?
				@person[:photo] = request.protocol + request.host_with_port + "/" + user.photo
			end
			@joined = []
			EventAttendee.where(user_id: user.id).each do |joined|
				event = Event.where(id: joined.event_id).first
				currentEvent = {
			        id: event.id,
			        title: event.title,
			        description: event.description,
			        author: event.user.firstname + " " + event.user.lastname,
			        author_link: request.protocol + request.host_with_port + "/people?id=" + event.user.id.to_s, 
			        date: event.edate,
			        link: request.protocol + request.host_with_port + "/event/view?ei=" + event.id.to_s(),
			        photo: request.protocol + request.host_with_port + "/data/cover.jpg" 
			    }
			    if event.photo.present? 
			    	currentEvent[:photo] = request.protocol + request.host_with_port + "/" + event.photo
			    end
			    @joined.push(currentEvent);
			end
			@created = []
			Event.where(user_id: user.id).each do |event|
				currentEvent = {
			        id: event.id,
			        title: event.title,
			        description: event.description,
			        author: event.user.firstname + " " + event.user.lastname,
			        author_link: request.protocol + request.host_with_port + "/people?id=" + event.user.id.to_s, 
			        date: event.edate,
			        link: request.protocol + request.host_with_port + "/event/view?ei=" + event.id.to_s(),
			        photo: request.protocol + request.host_with_port + "/data/cover.jpg" 
			    }
			    if event.photo.present? 
			    	currentEvent[:photo] = request.protocol + request.host_with_port + "/" + event.photo
			    end
			    @created.push(currentEvent);
			end
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
							date: event.edate,
							hour: Event.where(id: event.id).pluck("hour(etime)").first.to_i(),
							minute: Event.where(id: event.id).pluck("minute(etime)").first.to_i(),
							lat: event.lat,
							lng: event.lng,
							ampm: event.ampm,
							address: event.address,
							category: event.category.id,
							photo: request.protocol + request.host_with_port + "/data/cover.jpg" 
						}
						if event.photo.present?
							@event[:photo] = request.protocol + request.host_with_port + "/" + event.photo
						end
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
					lng: -1,
					photo: request.protocol + request.host_with_port + "/data/cover.jpg" 
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
		render :json => { status: 0, id: event.id , redirectto: request.protocol + request.host_with_port + "/event/view?ei=" + event.id.to_s()}
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
					photo: request.protocol + request.host_with_port + "/data/avatar.jpg"
				},
				joining: false,
				photo: request.protocol + request.host_with_port + "/data/cover.jpg" 
			}
			if event.photo.present?
				@event[:photo] = request.protocol + request.host_with_port + "/" + event.photo
			end
			if user.photo.present?
				@event[:host][:photo] = request.protocol + request.host_with_port + "/" + user.photo
			end
			@attendees = [] 
			event_attendees = EventAttendee.where(event_id: event.id)
			if session[:user_id].present?
				@event[:joining] = EventAttendee.where(event_id: event.id, user_id: session[:user_id]).first.present?
				event_attendees = event_attendees.where.not(user_id: session[:user_id])
			end
			event_attendees.take(4).each do |attendee|
				curAttendee = {
					link: request.protocol + request.host_with_port + "/people?id=" + attendee.user_id.to_s()
				}
				photo = User.all.select(:photo).where(id: attendee.user_id).first.photo
				if photo.present?
					curAttendee[:photo] = request.protocol + request.host_with_port + "/" + photo
				end
				@attendees.push(curAttendee)
			end
			render  :layout => "application_alternate"
		else 
			redirect_to root_path
		end
	end

	def view_category
		c = params[:c]
		category = Category.where(name: c).first
		@category = {
			id: category.id,
	        name: category.name,
	        photo: ActionController::Base.helpers.asset_path(category.name + ".jpg"),
	        link:  request.protocol + request.host_with_port+ "/event/category?c=" + category.name,
	        events: []
		}
		Event.where(category_id: category.id).all.to_a.each do |event|
			currentEvent = {
	          id: event.id,
	          title: event.title,
	          description: event.description,
	          author: event.user.firstname + " " + event.user.lastname,
	          link: request.protocol + request.host_with_port + "/event/view?ei=" + event.id.to_s(),
	          photo: request.protocol + request.host_with_port + "/data/cover.jpg",
	          date: event.edate
	        }
	        if event.photo.present? 
	          currentEvent[:photo] = request.protocol + request.host_with_port + "/" + event.photo
	        end
	        @category[:events].push(currentEvent)
		end
	end

	def join_event
		event_id = params[:event_id]
		user_id = session[:user_id]
		if user_id.present?
			event = Event.where(id: event_id).first
			if event.present?
				if Time.now > event.edate
					render :json => {status: 4}
				elsif !EventAttendee.where(event_id: event_id, user_id: user_id).first.present?
					EventAttendee.create(event_id: event_id, user_id: user_id)
					render :json => { status: 0 }
				else
					render :json => { status: 1 }
				end
			else
				render :json => {status: 3 }
			end
		else
			render :json => { status: 2 }
		end
	end

	def leave_event
		event_id = params[:event_id]
		user_id = session[:user_id]
		if user_id.present?
			if EventAttendee.where(event_id: event_id, user_id: user_id).first.present?
				EventAttendee.where(event_id: event_id, user_id: user_id).first.destroy
				render :json => { status: 0 }
			else
				render :json => { status: 1 }
			end
		else
			render :json => { status: 2 }
		end
	end

	def get_attendees
		event_id = params[:event_id]
		if event_id.present?
			user_ids = EventAttendee.where(event_id: event_id).pluck(:user_id)
			attendees = []
			User.where("id in (?)", user_ids).to_a.each do |attendee|
				curAttendee = {
					id: attendee.id,
					name: attendee.firstname + " " + attendee.lastname,
					photo: request.protocol + request.host_with_port + "/data/avatar.jpg"
				}
				if attendee.photo.present?
					curAttendee[:photo] = request.protocol + request.host_with_port + "/" + attendee.photo
				end
				attendees.push(curAttendee)
			end
			render :json => {status: 0, attendees: attendees}
		else
			render :json => {status: 1}
		end
	end
end

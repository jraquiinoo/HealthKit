class Event < ActiveRecord::Base
	belongs_to :user
	belongs_to :category
	has_many :users, through: :event_attendee
	def self.create_event(user_id, title, description, date, time, address, lat, lng, photo, event_ampm, category)
		event = Event.create(user_id: user_id, title: title, description: description, 
			edate: date, etime: time, address: address, 
			lat: lat, lng: lng, ampm: event_ampm.to_i(), category_id: category.to_i())
		if photo.present?
			directory = "public/data/user/" + user_id.to_s() + "/events/" + event[:id].to_s()
			filename = photo.original_filename + ".jpg"
			require 'fileutils'
			unless File.directory?(directory)
			  FileUtils.mkdir_p(directory)
			end
		    path = File.join(directory, filename)
		    File.open(path, "w+b") { |f| f.write(photo.read) }
		    Event.update(event.id, :photo => "data/user/" + user_id.to_s() + "/events/" + event[:id].to_s() + "/" + filename)
		end
		event
	end

	def self.update_event(user_id, event_id, title, description, date, time, address, lat, lng, photo, event_ampm, category)
		event = Event.where(id: event_id).first
		if event.user_id == user_id
			event = Event.update(event_id, :title => title, :description => description, 
				:edate => date, :etime => time, 
				:address => address, :lat => lat, :lng => lng, :ampm => event_ampm.to_i(), :category_id => category.to_i())
			if photo.present?
				directory = "public/data/user/" + user_id.to_s() + "/events/" + event[:id].to_s()
				filename = photo.original_filename + ".jpg"
				require 'fileutils'
				unless File.directory?(directory)
				  FileUtils.mkdir_p(directory)
				end
				if event.photo.present?
					if File.exists?("public/" + event.photo)
						File.delete("public/" + event.photo)
					end
				end
			    path = File.join(directory, filename)
			    File.open(path, "w+b") { |f| f.write(photo.read) }
			    Event.update(event.id, :photo => "data/user/" + user_id.to_s() + "/events/" + event[:id].to_s() + "/" + filename)
			end
		end
		event
	end
end

class ApplicationController < ActionController::Base
	before_action :set_user
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  def index
    @categories = []
    Category.all.to_a.each do |category|
      events = []
      Event.where(category_id: category.id).take(3).to_a.each do |event|
        events.push({
          id: event.id,
          title: event.title,
          description: event.description,
          author: event.user.firstname + " " + event.user.lastname,
          link: "http://localhost:3000/event/view?ei=" + event.id.to_s(),
          photo: "http://localhost:3000/" + event.photo
          });
      end
      @categories.push({
        id: category.id,
        name: category.name,
        events: events,
        photo: ActionController::Base.helpers.asset_path(category.name + ".jpg")
      });
      @categories_json = @categories.to_json.html_safe
    end
  end

  def set_user
  	if session[:user_id].present?
  		logged_user = User.where(id: session[:user_id]).first
      if logged_user.present?
  		  @user = {
  			 id: logged_user.id,
  			 username: logged_user.username,
  			 firstname: logged_user.firstname,
  			 lastname: logged_user.lastname,
         name: logged_user.firstname + " " + logged_user.lastname
  		  }

      else
        redirect_to root_path
      end

  		directory = "public/" + logged_user.photo
  		if File.exists?(directory)
  			@user[:photo] = "http://localhost:3000/" + logged_user.photo
  		end
  	end
  end
end

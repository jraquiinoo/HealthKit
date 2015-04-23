class ApplicationController < ActionController::Base
	before_action :set_user, :init_categories
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  def index
    @categories = []
    @featured = []

    Category.all.to_a.each do |category|
      events = []
      Event.where("category_id = ? AND edate > curdate()", category.id).take(3).to_a.each_with_index do |event, index|
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
        events.push(currentEvent);
        if index == 0
          @featured.push(currentEvent)
        end
      end
      @categories.push({
        id: category.id,
        name: category.name,
        events: events,
        color: category.color,
        photo: ActionController::Base.helpers.asset_path(category.name + ".jpg"),
        link: request.protocol + request.host_with_port + "/event/category?c=" + category.name
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
         name: logged_user.firstname + " " + logged_user.lastname,
         photo: request.protocol + request.host_with_port + "/data/avatar.jpg"
  		  }

      else
        redirect_to root_path
      end
      if logged_user.photo.present?
  		  directory = "public/" + logged_user.photo
    		if File.exists?(directory)
    			@user[:photo] = request.protocol + request.host_with_port + "/" + logged_user.photo
    		end
      end
  	end
  end

  def init_categories
    @categories = []
    Category.all.to_a.each do |category|
     @categories.push({
        id: category.id,
        name: category.name,
        photo: ActionController::Base.helpers.asset_path(category.name + ".jpg"),
        link: request.protocol + request.host_with_port + "/event/category?c=" + category.name
      });
    end
  end
end

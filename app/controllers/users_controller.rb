class UsersController < ApplicationController
  def list
  	require_user
  	@users = User.paginate(page: params[:page], per_page: 5)
  end

  def index
  	if logged_in?
  		redirect_to users_path
  	end
  end

  def login
  	@user = User.new
  end

  def authenticate
  	@user = User.find_by_email(login_params[:email])
  	if @user && @user.authenticate(login_params[:password])
  		session[:user_id] = @user.id
  		redirect_to user_path(@user)
  	else
  		flash[:danger] = "Epic Fail!"
  		redirect_to login_path
  	end
  end

  def logout
  	session[:user_id] = nil
  	redirect_to root_path
  end

  def register
  	@user = User.new
  end

  def new
  	@user = User.new(register_params)
  	@user.email.downcase!
      # if simple_captcha_valid?
      #   render plain: "yes"
      # else
      #   render plain: "no"
      # end
  	if @user.save_with_captcha
  		flash[:success] = "Thanks for registering, please check your email for the confirmation link"
  		session[:user_id] = @user.id
      # UserMailer.registration_confirmation(@user).deliver
  		redirect_to users_path
  	else

      # render plain: @user.captcha
  		render "register"
  	end
  end

  def show
  	if logged_in?
      @user = User.find(params[:id])
    else
  		flash[:danger] = "You need to be a logged in user to do that"
  		redirect_to root_path
  	end
  end

  def edit
    require_user
    @user = User.find(params[:id])
    if logged_in? && current_user != @user
      flash[:danger] = "Only the profile owner may edit the profile"
      redirect_to user_path(@user)
    end
  end

  def update
    require_user
  	@user = User.find(params[:id])
    if @user.update(update_params)
      flash[:success] = "User info was updated successfully"
      redirect_to user_path(@user)
    else
      render "edit"
    end
  end

  def confirm_email
    @user = User.find_by_confirm_token(params[:id])
    if user
      user.email_activate
      flash[:success] = "Thank you! Your email is now confirmed"
      redirect_to login_path
    else
      flash[:danger] = "Confirmation link is invalid"
      redirect_to root_path
    end
  end

  private

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save!(:validate => false)
  end
  def login_params
  	params.require(:user).permit :email, :password
  end

  def register_params
  	params.require(:user).permit :email, :password, :password_confirmation, :avatar, :captcha, :captcha_key
  end

  def update_params
    params.require(:user).permit :email, :bio, :avatar
  end
end

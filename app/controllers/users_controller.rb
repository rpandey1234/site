class UsersController < ApplicationController
  before_filter :require_login, :only=>[:destroy, :create, :new, :edit]
  # TODO: should not allow logged in user from editing ALL profiles
  include ApplicationHelper
  
  # show all users
  def index
    @users = []
    if params[:is_alumni] == '0'
      puts "not alumni"
      @users = User.where("is_alumni = false")
    elsif params[:is_alumni] == '1'
      @users = User.where("is_alumni = true")
    else
      @users = User.all
    end
    respond_to do |format|
      format.html
      format.json { render json: @users.to_json(:methods => [:avatar_url]) }
    end
  end

  # return an HTML form for creating a new user
  def new
  end

  # POST: create a new user
  def create
    @user = User.new(params[:user])
    if @user.valid?
      @user.save
      flash[:notice] = "Successfully created new member!"
      redirect_to :action => :show, :id => @user.id
    else
      flash[:alert] = "There was an error in validating the new member"
      render :action => :new
    end
  end

  # Show member of specific id
  def show 
    @user = User.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user.to_json(:methods => [:avatar_url]) }
    end
  end

  def sunet
    @user = User.find_by_sunet(params[:sunet])
    # do error checking here
    redirect_to :action => :show, :id => @user.id
  end

  # return an HTML form for editing a user
  def edit
    @user = User.find_by_id(params[:id])
    @photos = Photo.find_all_by_user_id(params[:id])
  end

  # PUT: update a specific user
  def update
    @user = User.find_by_id(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Updated member!"
      redirect_to :action => :show, :id => @user.id
    else
      flash[:alert] = "Unable to update member. Try again"
      redirect_to :action => :edit
    end
  end

  # DELETE: delete a specific user
  def destroy
    User.destroy(params[:id])
    flash[:notice] = "Deleted member!"
    redirect_to :action => :index
  end

  # This endpoint should ONLY be hit with .json
  # If user is logged in, returns them as json object
  # else returns null
  # TODO: (performance) don't need to return full user object
  def get_cur_user
    @user = nil
    if is_logged_in session
      @user = User.find_by_sunet(session[:user_hash]["username"])
    end
    respond_to do |format|
      format.json { render json: @user }
    end
  end
end
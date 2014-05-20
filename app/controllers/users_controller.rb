class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  def index
    @users = User.all
    @user = User.new
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    if (excluded_ids = @user.group_user_rels.map(&:group_id)).any?
      @user_remaining_groups = Group.where("id NOT IN (?)", excluded_ids).to_a
    else
      @user_remaining_groups = Group.all.to_a
    end
    
    # Do not use relation to create the new model otherwise the partial
    # relation gets added to the group_user_rels list which mess
    # with the rendering of the list
    @group_user_rel = GroupUserRel.new(user_id: @user.id)
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    if (excluded_ids = @user.group_user_rels.map(&:group_id)).any?
      @user_remaining_groups = Group.where("id NOT IN (?)", excluded_ids).to_a
    else
      @user_remaining_groups = Group.all.to_a
    end
    
    # Do not use relation to create the new model otherwise the partial
    # relation gets added to the group_user_rels list which mess
    # with the rendering of the list
    @group_user_rel = GroupUserRel.new(user_id: @user.id)
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "#{@user.name} has been successfully created. Now you should add this user to some groups" }
        format.json { render json: @user, status: :created, location: @user }
      else
        @users = User.all
        format.html { render action: "index" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
  
  # GET /users/1/regenerate_sso_session
  # -- should not be 'GET' but anyway....
  def regenerate_sso_session
    @user = User.find(params[:id])
    @user.generate_sso_session!
    
    redirect_to users_path, notice: "#{@user.name}'s session got expired and regenerated. If this user is currently logged in your application then a new SSO handshake should automatically be triggered in roughly 3 minutes."
  end
end

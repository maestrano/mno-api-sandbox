class GroupUserRelsController < ApplicationController
  # GET /group_user_rels
  # GET /group_user_rels.json
  def index
    @group_user_rels = GroupUserRel.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @group_user_rels }
    end
  end

  # GET /group_user_rels/1
  # GET /group_user_rels/1.json
  def show
    @group_user_rel = GroupUserRel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group_user_rel }
    end
  end

  # GET /group_user_rels/new
  # GET /group_user_rels/new.json
  def new
    @group_user_rel = GroupUserRel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group_user_rel }
    end
  end

  # GET /group_user_rels/1/edit
  def edit
    @group_user_rel = GroupUserRel.find(params[:id])
  end

  # POST /group_user_rels
  # POST /group_user_rels.json
  def create
    @group_user_rel = GroupUserRel.new(params[:group_user_rel])

    respond_to do |format|
      if @group_user_rel.save
        format.html { redirect_to edit_user_path(@group_user_rel.user), notice: "#{@group_user_rel.user.name} has been added to the '#{@group_user_rel.group.name}' group" }
        format.json { render json: @group_user_rel, status: :created, location: @group_user_rel }
      else
        format.html { render action: "new" }
        format.json { render json: @group_user_rel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /group_user_rels/1
  # PUT /group_user_rels/1.json
  def update
    @group_user_rel = GroupUserRel.find(params[:id])

    respond_to do |format|
      if @group_user_rel.update_attributes(params[:group_user_rel])
        format.html { redirect_to @group_user_rel, notice: 'Group user rel was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group_user_rel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /group_user_rels/1
  # DELETE /group_user_rels/1.json
  def destroy
    @group_user_rel = GroupUserRel.find(params[:id])
    @user = @group_user_rel.user
    @group_user_rel.destroy

    respond_to do |format|
      format.html { redirect_to edit_user_path(@user) }
      format.json { head :no_content }
    end
  end
end

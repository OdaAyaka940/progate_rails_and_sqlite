class UsersController < ApplicationController
  def index
    @users = User.all
  end
  
  def show
    @user = User.find_by(id: params[:id])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(
      name: params[:name],
      email: params[:email],
      image_name: "default_user.jpg"
    )
    if @user.save
      flash[:notice] = "ユーザー登録が完了しました"
      redirect_to("/users/#{@user.id}")
    else
      render("users/new")
    end
  end
  
  def edit
    @user = User.find_by(id: params[:id])
  end
  
  def update
    @user = User.find_by(id: params[:id])
    # usersテーブルのidカラムがparams[:id]の値と一致するレコードを検索します。
    @user.name = params[:name]
    @user.email = params[:email]
    # 画像を保存する処理を追加してください
    if params[:image]
    @user.image_name = "#{@user.id}.jpg"
    #文字列にしたいので、文字列の中で@user.idという変数を使いたければ#{}で囲む
    image = params[:image]
    File.binwrite("public/user_images/#{@user.image_name}", image.read)
    end
    
    if @user.save
      flash[:notice] = "ユーザー情報を編集しました"
      redirect_to("/users/#{@user.id}")
    else
      render("users/edit")
    end
  end
  
end

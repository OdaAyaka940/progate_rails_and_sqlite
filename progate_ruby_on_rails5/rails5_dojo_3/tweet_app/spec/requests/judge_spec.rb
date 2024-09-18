require 'rails_helper'

RSpec.describe 'ensure_correct_user', type: :request do
  id = '9999'
  let(:flash_string) { '権限がありません' }
  let(:user) { User.create(id: id, name: 'にんじゃわんこ', email: 'wanko@prog-8.com', password: 'ninjawanko') }
  let(:another_user) { User.create(name: 'ひつじ仙人', email: 'hitsuji@prog-8.com', password: 'hitsujisennin') }
  before(:each) { Post.create(id: id, content: 'test_content') }
  before(:each) { allow_any_instance_of(ApplicationController).to receive(:session).and_return(user_id: user.id) }

  it '@@@自分のユーザー編集ページへのアクセス時にリダイレクトされています。@@@' do
    get "/users/#{user.id}/edit"
    expect(response).not_to have_http_status(302)
  end

  it '@@@ユーザー編集ページへのアクセス時にエラーが起きています。プレビューで確認してみましょう。@@@' do
    get "/users/#{user.id}/edit"
    expect(response).to have_http_status(200)
  end

  it '@@@ログインしているユーザーと異なるユーザーの詳細ページにアクセスした時に、編集ページへのリンクが表示されています。@@@' do
    get "/users/#{another_user.id}"
    expect(response.body).not_to include('編集')
  end

  it '@@@「localhost:3000/users/1/update」のようなURLへのアクセス時にエラーが起きています。プレビューで確認してみましょう。@@@' do
    expect { post "/users/#{user.id}/update" }.not_to raise_error
  end

  it '@@@「localhost:3000/users/異なるユーザーのid/edit」というURLにアクセス制限がかかっていません。@@@' do
    get "/users/#{another_user.id}/edit"
    expect(response).to redirect_to(%r{/posts/index[?"]})
  end

  it '@@@「/users/異なるユーザーのid/edit」というURLにアクセスした際にフラッシュメッセージが設定されていません。@@@' do
    get "/users/#{another_user.id}/edit"
    expect(flash[:notice]).to be_present
  end

  it '@@@「/users/異なるユーザーのid/edit」というURLにアクセスした際のフラッシュメッセージが間違っています。@@@' do
    get "/users/#{another_user.id}/edit"
    expect(flash[:notice]).to eq(flash_string)
  end

  it '@@@「localhost:3000/users/異なるユーザーのid/update」というURLにアクセス制限がかかっていません。@@@' do
    post "/users/#{another_user.id}/update"
    expect(response).to redirect_to(%r{/posts/index[?"]})
  end

  it '@@@「/users/異なるユーザーのid/update」というURLにアクセスした際にフラッシュメッセージが設定されていません。@@@' do
    post "/users/#{another_user.id}/update"
    expect(flash[:notice]).to be_present
  end

  it '@@@「/users/異なるユーザーのid/update」というURLにアクセスした際のフラッシュメッセージが間違っています。@@@' do
    post "/users/#{another_user.id}/update"
    expect(flash[:notice]).to eq(flash_string)
  end

  forbid_access_paths = ['/users/:id/edit', '/users/:id/update']

  # ルーティングの一覧を取得する(http://qiita.com/ayasuda/items/a2b0c818e8b5efeb44cf)
  all_routes = Rails.application.routes.routes
  inspector = ActionDispatch::Routing::RoutesInspector.new(all_routes)
  all_paths = inspector.format(ActionDispatch::Routing::ConsoleFormatter.new, ENV['CONTROLLER']).scan(%r{(/.*?)\(}).flatten

  accessible_paths = all_paths - forbid_access_paths

  accessible_paths.each do |path|
    url = 'localhost:3000'
    url += path if path != '/'

    it "@@@「#{url}」にアクセス制限をかける必要はありません。@@@" do
      path.gsub!(/:id/, id) if path.match(/:id/)
      if path.match(/create|update|destroy|logout/)
        post path
      else
        get path
      end

      expect(flash[:notice]).not_to eq(flash_string)
    end
  end
end

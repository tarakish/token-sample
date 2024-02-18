# README
## What is this repository
Rails 7.1にて追加された`ActiveRecord::Base.generates_token_for`を試してみるためのサンプルアプリケーション。
リリースノート：https://railsguides.jp/7_1_release_notes.html#activerecord-base-generates-token-for%E3%81%8C%E8%BF%BD%E5%8A%A0

## How `ActiveRecord::Base.generates_token_for` is used
#### 1. Taskモデルにて、5秒でexpireされる`:upadte_task`トークンを生成する定義を追加
```ruby
# app/models/task.rb
class Task < ApplicationRecord
  generates_token_for :update_task, expires_in: 5.seconds
end
```

#### 2. Task編集ページへのアクセス時にtokenを発行し、hidden_fieldに値をセット。
```html
<!-- app/views/tasks/edit.html.erb -->
<%= form_with(model: task, local: true) do |form| %>
  ...
  <% if @task.persisted? %>
    <%= form.hidden_field :update_task_token, value: @task.generate_token_for(:update_task) %>
  <% end %>
  ...
<% end %>
```

#### 3. PUTリクエスト時のパラメーターにtokenを含めて送信

#### 4. Updateアクションで受け取ったtokenからTaskを取得し、取得できない場合はメッセージを含めて編集ページを再renderする
```ruby
# app/controllers/tasks_controller.rb
def update
  @task = Task.find_by_token_for(:update_task, params[:task][:update_task_token])

  if @task.nil?
    set_task
    @task.errors.add(:base, STUPID_TIMEUP_MESSAGE)
    render :edit, status: :unprocessable_entity
  else
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to task_url(@task), notice: "Task was successfully updated." }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end
end
```

これらの実装により、編集ページへアクセスしてから5秒以内にSubmitしなければ更新できないTask管理アプリケーションが完成した。

## Demo
#### 5秒以内にSubmitできなかったとき
[![Image from Gyazo](https://i.gyazo.com/172ce276c3d62200c27e3f6aa4c97faf.gif)](https://gyazo.com/172ce276c3d62200c27e3f6aa4c97faf)
#### 5秒以内にSubmitできたとき
[![Image from Gyazo](https://i.gyazo.com/fac4a013345e54e99e28fe9b96fb8351.gif)](https://gyazo.com/fac4a013345e54e99e28fe9b96fb8351)

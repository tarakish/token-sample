class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit destroy ]

  STUPID_TIMEUP_MESSAGE = '
    時間切れだ！
    チャンスはもうない、終わりだ！
    もう戻れない。
    時計は既に最後の刻を打ち、運命の扉は閉ざされた。
    待っても、懇願しても、時間は決して巻き戻らない。
    逃した機会は永遠に失われ、後悔が心を覆う。
    今、この時をどれほど大切にすべきだったか、痛感しているだろう。しかし、もう遅い。
    時間の砂はすべて落ちた。残されたのは、何をしても変えられない結果と、その結果を受け入れるしかない現実だけ。これが、時間切れの真実だ！
  '

  # GET /tasks or /tasks.json
  def index
    @tasks = Task.all
  end

  # GET /tasks/1 or /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks or /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to task_url(@task), notice: "Task was successfully created." }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
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

  # DELETE /tasks/1 or /tasks/1.json
  def destroy
    @task.destroy!

    respond_to do |format|
      format.html { redirect_to tasks_url, notice: "Task was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.require(:task).permit(:title, :description)
    end
end

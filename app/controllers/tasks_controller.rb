class TasksController < ApplicationController
    def index
        @tasks = Task.all
    end

    def show
        @task = Task.find params[:id]
    end

    def new

    end

    def create
        @task = Task.new task_params
        if @task.save
            redirect_To @task
        else
            render 'new'
        end
    end

    private 
        def task_params
            params.require(:task).permit :title, :text
        end
end

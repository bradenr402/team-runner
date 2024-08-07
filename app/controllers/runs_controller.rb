class RunsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_run, only: %i[show edit update destroy]

  def show
  end

  def new
    @run = current_user.runs.new
  end

  def create
    @run = current_user.runs.build(run_params)
    if params[:run][:duration_input].present?
      @run.duration = parse_duration(params[:run][:duration_input])
    end

    if @run.save
      redirect_to @run, success: 'Run was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if params[:run][:duration_input].present?
      @run.duration = parse_duration(params[:run][:duration_input])
    end

    if @run.update(run_params)
      redirect_to @run, success: 'Run was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @run.destroy
    redirect_to runs_path, success: 'Run was successfully deleted.'
  end

  private

  def set_run = @run = Run.find(params[:id])

  def run_params =
    params.require(:run).permit(
      :distance,
      :duration,
      :date,
      :comments,
      :duration_input
    )

  def parse_duration(input)
    parts = input.split(':').map(&:to_i)
    case parts.length
    when 2
      minutes, seconds = parts
      ActiveRecord::Base
        .connection
        .execute("SELECT '#{minutes} minutes #{seconds} seconds'::interval")
        .first[
        'interval'
      ]
    when 3
      hours, minutes, seconds = parts
      ActiveRecord::Base
        .connection
        .execute(
          "SELECT '#{hours} hours #{minutes} minutes #{seconds} seconds'::interval"
        )
        .first[
        'interval'
      ]
    end
  end
end

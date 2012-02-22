class NoticeObserver < Mongoid::Observer
  def after_create(notice)
    if ::Bushido::Platform.on_bushido?
      @notice = notice
      @err    = notice.err
      @app    = notice.problem.app

      human_message = notice_title(notice.err.problem)
      human_message += " see more at #{Rails.application.routes.url_helpers.app_err_notice_url(@app, @err, @notice, :host => ENV['BUSHIDO_DOMAIN'])}"
      event = {
        :category => :app,
        :name     => :errored,
        :data     => {
          :human  => human_message,
          :source => "Errbit",
          :url    => Rails.application.routes.url_helpers.app_err_notice_url(@app, @err, @notice, :host => ENV['BUSHIDO_DOMAIN'])
        }
      }
      ::Bushido::Event.publish(event)
    end
  end

  def notice_title(notice)
    "[#{@app.name}][#{@notice.environment_name}] #{@notice.message}"
  end
end

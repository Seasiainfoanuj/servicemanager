module BuildsHelper

  def build_progress(build)
    percent_complete = number_to_percentage(build.build_orders.where(:status => 'complete').length.to_f / build.build_orders.length.to_f * 100, precision: 0)
  end

end

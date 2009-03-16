class Profile
  def self.measure(msg=nil)
    total_time = Benchmark.realtime {  yield }
    total_time = 0.0001 if total_time < 0.0001 # otherwise it formats like 8e-5
    Rails.logger.info "#{msg} time took #{total_time} seconds to complete"
    return total_time
  end
end
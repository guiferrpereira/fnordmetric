class FnordMetric::Reactor

  def initialize
    @namespaces = FnordMetric.namespaces
  end

  def execute(socket, event, messages = [])
    return false unless event["namespace"]
    return false unless ns = @namespaces[event["namespace"].to_sym]
    messages << discover(ns) if event["type"] == "discover_request"
    messages << widget(ns, event) if event["type"] == "widget_request"
    messages.flatten.each{ |m| socket.send(m.to_json) }
  end

private

  def widget(namespace, event)
    "FnordMetric::#{event["klass"]}".constantize.execute(namespace, event) # FIXPAUL
  end

  def discover(namespace)
    [namespace.dashboards.map do |dash_key, gauge|
      { "type" => "discover_response", "gauge_key" => dash_key, "view" => "dashboard" }
    end,
    namespace.gauges.map do |gauge_key, gauge|
      { "type" => "discover_response", "gauge_key" => gauge_key, "view" => "gauge" }
    end]
  end

end
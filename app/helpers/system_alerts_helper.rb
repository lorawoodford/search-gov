module SystemAlertsHelper
  def show_system_alerts(system_alerts)
    return if system_alerts.blank?
    content = system_alerts.collect do |system_alert|
      content_tag(:div, system_alert.message)
    end
    content_tag(:div, content.join("\n").html_safe, :class => 'notice')
  end
end
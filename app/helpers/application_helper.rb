module ApplicationHelper

  def get_errors(model_object, error_heading = "")
    output = ""
    if model_object.errors.any?
      output = "<div id='error_explanation' class='alert alert-error'>"
      if error_heading.present?
        output += "\n  " + error_heading
      else
        output += "\n  <h2>" + pluralize(model_object.errors.count, "error") + " prohibited this " + model_object.class.to_s.humanize.downcase + " from being saved:</h2>"
      end
      output += "\n  <ul>"
      model_object.errors.full_messages.each do |msg|
        output += "\n    <li>" + msg  + "</li>"
      end
      output += "\n  </ul>"
      output += "\n</div>"
    end
    output.html_safe
  end

end
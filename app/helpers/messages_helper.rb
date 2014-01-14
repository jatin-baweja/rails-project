module MessagesHelper

  def render_content_partial_for(message_object)
    render partial: 'messages/content', locals: { :message => message_object }
  end

end
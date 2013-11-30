class PublishProjectJob < Struct.new(:project)

  def perform
    if project.approved?
      ProjectStatusNotifier.published(project).deliver
    end
  end

end

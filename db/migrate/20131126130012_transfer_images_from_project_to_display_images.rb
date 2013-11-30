class TransferImagesFromProjectToDisplayImages < ActiveRecord::Migration
  def up
    @projects = Project.all
    @projects.each do |project|
      disp_image = project.display_images.build
      disp_image.picture = project.image
      disp_image.primary = true
      disp_image.save!
    end
  end

  def down
    @projects = Project.all
    @projects.each do |project|
      disp_image = project.display_images.where(primary: true)
      project.image = disp_image.picture
      project.save!
    end
  end
end

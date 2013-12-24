module Projects
  module Setter

    private

      def set_project
        unless (@project = Project.find_by_permalink(params[:id]))
          redirect_to root_path, "No Project Found"
        end
      end

      def validate_owner
        unless(@project.owner?(current_user))
          redirect_to project_path(@project), notice: "Only Project Owner can edit this Project"
        end
      end

  end
end

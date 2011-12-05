require_dependency 'projects_helper'

module ProjectstreeviewProjectsHelperPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    
    ###
    # Compatibility helpers
    ###
    
    # Redmine Core trunk@r2734 (0.9-devel)
    # Returns true if the method is defined, else it returns false
    def users_by_role_implemented
      return ProjectsController.method_defined?("users_by_role")
    end

    # Redmine Core trunk@r2750 (0.9-devel)
    # Returns true if the method is defined, else it returns false
    def authorize_global_implemented
      return ApplicationController.method_defined?("authorize_global")
    end
	
	def render_project_progress(project)
		s = ''
    if project.issues.open.count > 0
      issues_closed_pourcent = (1 - project.issues.open.count.to_f/project.issues.count) * 100
      s << "<div>Issues: " +
        link_to("#{project.issues.open.count} open", :controller => 'issues', :action => 'index', :project_id => project, :set_filter => 1) +
        "<small> / #{project.issues.count} total</small></div>" +
        progress_bar(issues_closed_pourcent, :width => '30em', :legend => '%0.0f%' % issues_closed_pourcent)
    end

    unless project.versions.open.empty?
      s << "<div>"
      project.versions.open.reverse_each do |version|
        unless version.completed?
          s << link_to_version(version) + ": " +
            link_to_if(version.open_issues_count > 0, l(:label_x_open_issues_abbr, :count => version.open_issues_count), :controller => 'issues', :action => 'index', :project_id => version.project, :status_id => 'o', :fixed_version_id => version, :set_filter => 1) +
            "<small> / " + link_to_if(version.closed_issues_count > 0, l(:label_x_closed_issues_abbr, :count => version.closed_issues_count), :controller => 'issues', :action => 'index', :project_id => version.project, :status_id => 'c', :fixed_version_id => version, :set_filter => 1) + "</small>" + ". "
          s << due_date_distance_in_words(version.effective_date) if version.effective_date
          s << "<br>" +
            progress_bar([version.closed_pourcent, version.completed_pourcent], :width => '30em', :legend => ('%0.0f%' % version.completed_pourcent))
        end
      end
      s << "</div>"
    end
	end
	
    def favorite_project_modules_links(project)
    links = []
    menu_items_for(:project_menu, project) do |node|
       links << link_to(extract_node_details(node, project)[0], extract_node_details(node, project)[1]) unless node.name == :overview
    end
    links.join(", ")
  end


  end # Close the module ProjectstreeviewProjectsHelperPatch::InstanceMethods
end # Close the module ProjectstreeviewProjectsHelperPatch
ProjectsHelper.send(:include, ProjectstreeviewProjectsHelperPatch)

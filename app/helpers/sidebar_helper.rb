module SidebarHelper
  def split_by_header(string)
    parts = string.split("<h3")
    retval = "<table>"
    index = 0
    colors = [nil,"FF0066","FF3333","FF6600","006666","003366","3366FF"]
    parts.each_with_index do |part, idx|
      unless part.to_s == ""
        if index == 0 
          retval << "<tr>"
        end
        #retval << "<td><h3 style=\"background: ##{colors[idx]} url(/images/theme/black-corner.png) no-repeat top left; height: 20px; border-top: 2px solid #666; padding-left: 25px;margin-bottom: 13px;\"" << part << "</td>"
        retval << "<td><h3" << part << "</td>"
        index += 1
        if index > 2
          index = 0
          retval << "</tr>"
        end
      end
    end
    retval << "</table>"
  end

  def render_sidebars(*sidebars)
    begin
      (sidebars.blank? ? Sidebar.find(:all, :order => 'active_position ASC') : sidebars).inject('') do |acc, sb|
        @sidebar = sb
        sb.parse_request(contents, params)
        acc + render_sidebar(sb)
      end
    rescue
      _("It seems something went wrong. Maybe some of your sidebars are actually missing and you should either reinstall them or remove them manually
        ")
    end
  end

  def render_sidebar(sidebar)
    if sidebar.view_root
      # Allow themes to override sidebar views
      view_root = File.expand_path(sidebar.view_root)
      rails_root = File.expand_path(RAILS_ROOT)
      if view_root =~ /^#{Regexp.escape(rails_root)}/
        new_root = view_root[rails_root.size..-1]
        new_root.sub! %r{^/?vendor/}, ""
        new_root.sub! %r{/views}, ""
        new_root = File.join(this_blog.current_theme.path, "views", new_root)
        view_root = new_root if File.exists?(File.join(new_root, "content.rhtml"))
      end
      render_to_string(:file => "#{view_root}/content.rhtml",
                       :locals => sidebar.to_locals_hash)
    else
      render_to_string(:partial => sidebar.content_partial,
                       :locals => sidebar.to_locals_hash)
    end
  end

  def articles?
    not Article.first.nil?
  end

  def trackbacks?
    not Trackback.first.nil?
  end

  def comments?
    not Comment.first.nil?
  end

end

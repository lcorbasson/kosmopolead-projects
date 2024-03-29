# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'coderay'
require 'coderay/helpers/file_type'
require 'forwardable'
require 'cgi'

module ApplicationHelper
  include Redmine::WikiFormatting::Macros::Definitions
  include GravatarHelper::PublicMethods

  extend Forwardable
  def_delegators :wiki_helper, :wikitoolbar_for, :heads_for_wiki_formatter

  def current_role
    @current_role ||= User.current.role_for_project(@project)
  end

  # Return true if user is authorized for controller/action, otherwise false
  def authorize_for(controller, action)
    User.current.allowed_to?({:controller => controller, :action => action}, @project)
  end

  # Display a link if user is authorized
  def link_to_if_authorized(name, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to(name, options, html_options, *parameters_for_method_reference) 
  end

  # Display a link to remote if user is authorized
  def link_to_remote_if_authorized(name, options = {}, html_options = nil)
    url = options[:url] || {}
    link_to_remote(name, options, html_options) if authorize_for(url[:controller] || params[:controller], url[:action])
  end

  # Display a link to user's account page
  def link_to_user(user, options={})
    (user && !user.anonymous?) ? link_to(user.name(options[:format]), :controller => 'account', :action => 'show', :id => user) : 'Anonymous'
  end

  def link_to_issue(issue, options={})
    options[:class] ||= ''
    options[:class] << ' issue'
    options[:class] << ' closed' if issue.closed?
    link_to "#{issue.subject}", {:controller => "issues", :action => "show", :id => issue,:project_id=>issue.project}, options
  end

  def link_to_project(project, options={})
    options[:class] ||= ''
    options[:class] << ' project'  
    link_to_remote "#{project.acronym}", {:url=>project_path(project),:method=>:get}, options
  end

  # Generates a link to an attachment.
  # Options:
  # * :text - Link text (default to attachment filename)
  # * :download - Force download (default: false)
  def link_to_attachment(attachment, options={})
    text = options.delete(:text) || truncate(attachment.file_file_name,18)
    action = options.delete(:download) ? 'download' : 'show'

    link_to(h(text), {:controller => 'file_attachments', :action => action, :id => attachment, :filename => attachment.file_file_name }, options)
  end

  def toggle_link(name, id, options={})
    onclick = "Element.toggle('#{id}'); "
    onclick << (options[:focus] ? "Form.Element.focus('#{options[:focus]}'); " : "this.blur();")
    onclick << (options[:second_element] ?    "Element.toggle('#{options[:second_element]}');$('#{options[:second_element]}').blur();" : "")
    onclick << "return false;"
    link_to(name, "#", :onclick => onclick,:class=>"button btn_orange corner-all")
  end

  def image_to_function(name, function, html_options = {})
    html_options.symbolize_keys!
    tag(:input, html_options.merge({
        :type => "image", :src => image_path(name),
        :onclick => (html_options[:onclick] ? "#{html_options[:onclick]}; " : "") + "#{function};"
        }))
  end

  def prompt_to_remote(name, text, param, url, html_options = {})
    html_options[:onclick] = "promptToRemote('#{text}', '#{param}', '#{url_for(url)}'); return false;"
    link_to name, {}, html_options
  end

  def format_date(date)
    return nil unless date
    # "Setting.date_format.size < 2" is a temporary fix (content of date_format setting changed)
    @date_format ||= (Setting.date_format.blank? || Setting.date_format.size < 2 ? l(:general_fmt_date) : Setting.date_format)
    date.strftime(@date_format)
  end

  def format_time(time, include_date = true)
    return nil unless time
    time = time.to_time if time.is_a?(String)
    zone = User.current.time_zone
    local = zone ? time.in_time_zone(zone) : (time.utc? ? time.localtime : time)
    @date_format ||= (Setting.date_format.blank? || Setting.date_format.size < 2 ? l(:general_fmt_date) : Setting.date_format)
    @time_format ||= (Setting.time_format.blank? ? l(:general_fmt_time) : Setting.time_format)
    include_date ? local.strftime("#{@date_format} #{@time_format}") : local.strftime(@time_format)
  end
  
  def format_activity_title(text)
    h(truncate_single_line(text, 100))
  end
  
  def format_activity_day(date)
    date == Date.today ? l(:label_today).titleize : format_date(date)
  end
  
  def format_activity_description(text)
    h(truncate(text.to_s, 250).gsub(%r{<(pre|code)>.*$}m, '...'))
  end

  def distance_of_date_in_words(from_date, to_date = 0)
    from_date = from_date.to_date if from_date.respond_to?(:to_date)
    to_date = to_date.to_date if to_date.respond_to?(:to_date)
    distance_in_days = (to_date - from_date).abs
    lwr(:actionview_datehelper_time_in_words_day, distance_in_days)
  end

  def due_date_distance_in_words(date)
    if date
      l((date < Date.today ? :label_roadmap_overdue : :label_roadmap_due_in), distance_of_date_in_words(Date.today, date))
    end
  end

  def render_page_hierarchy(pages, node=nil)
    content = ''
    if pages[node]
      content << "<ul class=\"pages-hierarchy\">\n"
      pages[node].each do |page|
        content << "<li>"
        content << link_to(h(page.pretty_title), {:controller => 'wiki', :action => 'index', :id => page.project, :page => page.title},
                           :title => (page.respond_to?(:updated_on) ? l(:label_updated_time, distance_of_time_in_words(Time.now, page.updated_on)) : nil))
        content << "\n" + render_page_hierarchy(pages, page.id) if pages[page.id]
        content << "</li>\n"
      end
      content << "</ul>\n"
    end
    content
  end
  
  # Renders flash messages
  def render_flash_messages
    s = ''
    flash.each do |k,v|
      s << content_tag('div', v, :class => "flash #{k}")
    end
    s
  end

  # Truncates and returns the string as a single line
  def truncate_single_line(string, *args)
    truncate(string, *args).gsub(%r{[\r\n]+}m, ' ')
  end

  def html_hours(text)
    text.gsub(%r{(\d+)\.(\d+)}, '<span class="hours hours-int">\1</span><span class="hours hours-dec">.\2</span>')
  end

  def authoring(created, author, options={})
    time_tag = @project.nil? ? content_tag('acronym', distance_of_time_in_words(Time.now, created), :title => format_time(created)) :
                               link_to(distance_of_time_in_words(Time.now, created), 
                                       activity_project_path(@project, :from => created.to_date),
                                       :title => format_time(created))
    author_tag = (author.is_a?(User) && !author.anonymous?) ? link_to(h(author), :controller => 'account', :action => 'show', :id => author) : h(author || 'Anonymous')
    l(options[:label] || :label_added_time_by, author_tag, time_tag)
  end

  def l_or_humanize(s, options={})
    k = "#{options[:prefix]}#{s}".to_sym
    l_has_string?(k) ? l(k) : s.to_s.humanize
  end

  def day_name(day)
    l(:general_day_names).split(',')[day-1]
  end

  def month_name(month)
    l(:actionview_datehelper_select_month_names).split(',')[month-1]
  end

  def syntax_highlight(name, content)
    type = CodeRay::FileType[name]
    type ? CodeRay.scan(content, type).html : h(content)
  end

  def to_path_param(path)
    path.to_s.split(%r{[/\\]}).select {|p| !p.blank?}
  end

  def pagination_links_full(paginator, count=nil, options={})
    page_param = options.delete(:page_param) || :page
    url_param = params.dup
    # don't reuse params if filters are present

    if options[:update]
      url_param.clear if url_param.has_key?(:set_filter)
    end

    html = ''
   
         
          html << link_to_remote(('&#171; ' + l(:label_previous)),
                            {:update => !options[:update] ? "" : 'content_wrapper',
                             :url => url_param.merge(page_param => paginator.current.previous),
                             :method=>:get,
                             :complete => 'window.scrollTo(0,0)'},
                            {:href => url_for(:params => url_param.merge(page_param => paginator.current.previous))}) + ' ' if paginator.current.previous

          html << (pagination_links_each(paginator, options) do |n|
            link_to_remote(n.to_s,
                            {:url => {:params => url_param.merge(page_param => n)},
                             :update => !options[:update] ? "" : 'content_wrapper',
                             :method=>:get,
                             :complete => 'window.scrollTo(0,0)'},
                            {:href => url_for(:params => url_param.merge(page_param => n))})
          end || '')

          html << ' ' + link_to_remote((l(:label_next) + ' &#187;'),
                                       {:update => !options[:update] ? "" : 'content_wrapper',
                                        :url => url_param.merge(page_param => paginator.current.next),
                                        :method=>:get,
                                        :complete => 'window.scrollTo(0,0)'},
                                       {:href => url_for(:params => url_param.merge(page_param => paginator.current.next))}) if paginator.current.next

          unless count.nil?
            html << [" (#{paginator.current.first_item}-#{paginator.current.last_item}/#{count})", per_page_links(paginator.items_per_page, :update => options[:update])].compact.join(' | ' )
          end
   

    html
  end

  def per_page_links(selected=nil, options={})
    url_param = params.dup
    url_param.clear if url_param.has_key?(:set_filter)

    
     
      links = Setting.per_page_options_array.collect do |n|
        n == selected ? n : link_to_remote(n, {:update => !options[:update] ? "" : 'content_wrapper', :url => params.dup.merge(:per_page => n),:method=>:get},
                                              {:href => url_for(url_param.merge(:per_page => n))})
      end
   
    links.size > 1 ? l(:label_display_per_page, links.join(', ')) : nil
  end

  def breadcrumb(*args)
    elements = args.flatten
    elements.any? ? content_tag('p', args.join(' &#187; ') + ' &#187; ', :class => 'breadcrumb') : nil
  end

  def html_title(*args)
    if args.empty?
      title = []
      title << @project.name if @project
      title += @html_title if @html_title
      title << "Kosmopolead projects"
      title.compact.join(' - ')
    else
      @html_title ||= []
      @html_title += args
    end
  end

  def accesskey(s)
    Redmine::AccessKeys.key_for s
  end

  # Formats text according to system settings.
  # 2 ways to call this method:
  # * with a String: textilizable(text, options)
  # * with an object and one of its attribute: textilizable(issue, :description, options)
  def textilizable(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    case args.size
    when 1
      obj = options[:object]
      text = args.shift
    when 2
      obj = args.shift
      text = obj.send(args.shift).to_s
    else
      raise ArgumentError, 'invalid arguments to textilizable'
    end
    return '' if text.blank?

    only_path = options.delete(:only_path) == false ? false : true

    # when using an image link, try to use an attachment, if possible
    attachments = options[:file_attachments] || (obj && obj.respond_to?(:file_attachments) ? obj.file_attachments : nil)

    if attachments
      attachments = attachments.sort_by(&:created_on).reverse
      text = text.gsub(/!((\<|\=|\>)?(\([^\)]+\))?(\[[^\]]+\])?(\{[^\}]+\})?)(\S+\.(bmp|gif|jpg|jpeg|png))!/i) do |m|
        style = $1
        filename = $6.downcase
        # search for the picture in attachments
        if found = attachments.detect { |att| att.filename.downcase == filename }
          image_url = url_for :only_path => only_path, :controller => 'attachments', :action => 'download', :id => found
          desc = found.description.to_s.gsub(/^([^\(\)]*).*$/, "\\1")
          alt = desc.blank? ? nil : "(#{desc})"
          "!#{style}#{image_url}#{alt}!"
        else
          m
        end
      end
    end

    text = Redmine::WikiFormatting.to_html(Setting.text_formatting, text) { |macro, args| exec_macro(macro, obj, args) }

    # different methods for formatting wiki links
    case options[:wiki_links]
    when :local
      # used for local links to html files
      format_wiki_link = Proc.new {|project, title, anchor| "#{title}.html" }
    when :anchor
      # used for single-file wiki export
      format_wiki_link = Proc.new {|project, title, anchor| "##{title}" }
    else
      format_wiki_link = Proc.new {|project, title, anchor| url_for(:only_path => only_path, :controller => 'wiki', :action => 'index', :id => project, :page => title, :anchor => anchor) }
    end

    project = options[:project] || @project || (obj && obj.respond_to?(:project) ? obj.project : nil)

    # Wiki links
    #
    # Examples:
    #   [[mypage]]
    #   [[mypage|mytext]]
    # wiki links can refer other project wikis, using project name or identifier:
    #   [[project:]] -> wiki starting page
    #   [[project:|mytext]]
    #   [[project:mypage]]
    #   [[project:mypage|mytext]]
    text = text.gsub(/(!)?(\[\[([^\]\n\|]+)(\|([^\]\n\|]+))?\]\])/) do |m|
      link_project = project
      esc, all, page, title = $1, $2, $3, $5
      if esc.nil?
        if page =~ /^([^\:]+)\:(.*)$/
          link_project = Project.find_by_name($1) || Project.find_by_identifier($1)
          page = $2
          title ||= $1 if page.blank?
        end

        if link_project && link_project.wiki
          # extract anchor
          anchor = nil
          if page =~ /^(.+?)\#(.+)$/
            page, anchor = $1, $2
          end
          # check if page exists
          wiki_page = link_project.wiki.find_page(page)
          link_to((title || page), format_wiki_link.call(link_project, Wiki.titleize(page), anchor),
                                   :class => ('wiki-page' + (wiki_page ? '' : ' new')))
        else
          # project or wiki doesn't exist
          title || page
        end
      else
        all
      end
    end

    # Redmine links
    #
    # Examples:
    #   Issues:
    #     #52 -> Link to issue #52
    #   Changesets:
    #     r52 -> Link to revision 52
    #     commit:a85130f -> Link to scmid starting with a85130f
    #   Documents:
    #     document#17 -> Link to document with id 17
    #     document:Greetings -> Link to the document with title "Greetings"
    #     document:"Some document" -> Link to the document with title "Some document"
    #   Versions:
    #     version#3 -> Link to version with id 3
    #     version:1.0.0 -> Link to version named "1.0.0"
    #     version:"1.0 beta 2" -> Link to version named "1.0 beta 2"
    #   Attachments:
    #     attachment:file.zip -> Link to the attachment of the current object named file.zip
    #   Source files:
    #     source:some/file -> Link to the file located at /some/file in the project's repository
    #     source:some/file@52 -> Link to the file's revision 52
    #     source:some/file#L120 -> Link to line 120 of the file
    #     source:some/file@52#L120 -> Link to line 120 of the file's revision 52
    #     export:some/file -> Force the download of the file
    #  Forum messages:
    #     message#1218 -> Link to message with id 1218
    text = text.gsub(%r{([\s\(,\-\>]|^)(!)?(attachment|document|version|commit|source|export|message)?((#|r)(\d+)|(:)([^"\s<>][^\s<>]*?|"[^"]+?"))(?=(?=[[:punct:]]\W)|\s|<|$)}) do |m|
      leading, esc, prefix, sep, oid = $1, $2, $3, $5 || $7, $6 || $8
      link = nil
      if esc.nil?
        if prefix.nil? && sep == 'r'
          if project && (changeset = project.changesets.find_by_revision(oid))
            link = link_to("r#{oid}", {:only_path => only_path, :controller => 'repositories', :action => 'revision', :id => project, :rev => oid},
                                      :class => 'changeset',
                                      :title => truncate_single_line(changeset.comments, 100))
          end
        elsif sep == '#'
          oid = oid.to_i
          case prefix
          when nil
            if issue = Issue.find_by_id(oid, :include => [:project, :status], :conditions => Project.visible_by(User.current))
              link = link_to("##{oid}", {:only_path => only_path, :controller => 'issues', :action => 'show', :id => oid},
                                        :class => (issue.closed? ? 'issue closed' : 'issue'),
                                        :title => "#{truncate(issue.subject, 100)} (#{issue.status.name})")
              link = content_tag('del', link) if issue.closed?
            end
          when 'document'
            if document = Document.find_by_id(oid, :include => [:project], :conditions => Project.visible_by(User.current))
              link = link_to h(document.title), {:only_path => only_path, :controller => 'documents', :action => 'show', :id => document},
                                                :class => 'document'
            end
          when 'version'
            if version = Version.find_by_id(oid, :include => [:project], :conditions => Project.visible_by(User.current))
              link = link_to h(version.name), {:only_path => only_path, :controller => 'versions', :action => 'show', :id => version},
                                              :class => 'version'
            end
          when 'message'
            if message = Message.find_by_id(oid, :include => [:parent, {:board => :project}], :conditions => Project.visible_by(User.current))
              link = link_to h(truncate(message.subject, 60)), {:only_path => only_path,
                                                                :controller => 'messages',
                                                                :action => 'show',
                                                                :board_id => message.board,
                                                                :id => message.root,
                                                                :anchor => (message.parent ? "message-#{message.id}" : nil)},
                                                 :class => 'message'
            end
          end
        elsif sep == ':'
          # removes the double quotes if any
          name = oid.gsub(%r{^"(.*)"$}, "\\1")
          case prefix
          when 'document'
            if project && document = project.documents.find_by_title(name)
              link = link_to h(document.title), {:only_path => only_path, :controller => 'documents', :action => 'show', :id => document},
                                                :class => 'document'
            end
          when 'version'
            if project && version = project.versions.find_by_name(name)
              link = link_to h(version.name), {:only_path => only_path, :controller => 'versions', :action => 'show', :id => version},
                                              :class => 'version'
            end
          when 'commit'
            if project && (changeset = project.changesets.find(:first, :conditions => ["scmid LIKE ?", "#{name}%"]))
              link = link_to h("#{name}"), {:only_path => only_path, :controller => 'repositories', :action => 'revision', :id => project, :rev => changeset.revision},
                                           :class => 'changeset',
                                           :title => truncate_single_line(changeset.comments, 100)
            end
          when 'source', 'export'
            if project && project.repository
              name =~ %r{^[/\\]*(.*?)(@([0-9a-f]+))?(#(L\d+))?$}
              path, rev, anchor = $1, $3, $5
              link = link_to h("#{prefix}:#{name}"), {:controller => 'repositories', :action => 'entry', :id => project,
                                                      :path => to_path_param(path),
                                                      :rev => rev,
                                                      :anchor => anchor,
                                                      :format => (prefix == 'export' ? 'raw' : nil)},
                                                     :class => (prefix == 'export' ? 'source download' : 'source')
            end
          when 'attachment'
            if attachments && attachment = attachments.detect {|a| a.filename == name }
              link = link_to h(attachment.filename), {:only_path => only_path, :controller => 'attachments', :action => 'download', :id => attachment},
                                                     :class => 'attachment'
            end
          end
        end
      end
      leading + (link || "#{prefix}#{sep}#{oid}")
    end

    text
  end

  # Same as Rails' simple_format helper without using paragraphs
  def simple_format_without_paragraph(text)
    text.to_s.
      gsub(/\r\n?/, "\n").                    # \r\n and \r -> \n
      gsub(/\n\n+/, "<br /><br />").          # 2+ newline  -> 2 br
      gsub(/([^\n]\n)(?=[^\n])/, '\1<br />')  # 1 newline   -> br
  end

  def error_messages_for(object_name, options = {})
    options = options.symbolize_keys
    object = instance_variable_get("@#{object_name}")
    if object && !object.errors.empty?
      # build full_messages here with controller current language
      full_messages = []
      object.errors.each do |attr, msg|
        next if msg.nil?
        msg = [msg] unless msg.is_a?(Array)
        if attr == "base"
          full_messages << l(*msg)
        else
          full_messages << "&#171; " + (l_has_string?("field_" + attr) ? l("field_" + attr) : object.class.human_attribute_name(attr)) + " &#187; " + l(*msg) unless attr == "custom_values"
        end
      end
      # retrieve custom values error messages
      if object.errors[:custom_values]
        object.custom_values.each do |v|
          v.errors.each do |attr, msg|
            next if msg.nil?
            msg = [msg] unless msg.is_a?(Array)
            full_messages << "&#171; " + v.custom_field.name + " &#187; " + l(*msg)
          end
        end
      end
      content_tag("div",
        content_tag(
          options[:header_tag] || "span", lwr(:gui_validation_error, full_messages.length) + ":"
        ) +
        content_tag("ul", full_messages.collect { |msg| content_tag("li", msg) }),
        "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation"
      )
    else
      ""
    end
  end

  def lang_options_for_select(blank=true)
    (blank ? [["(auto)", ""]] : []) +
      GLoc.valid_languages.collect{|lang| [ ll(lang.to_s, :general_lang_name), lang.to_s]}.sort{|x,y| x.last <=> y.last }
  end

  def label_tag_for(name, option_tags = nil, options = {})
    label_text = l(("field_"+field.to_s.gsub(/\_id$/, "")).to_sym) + (options.delete(:required) ? @template.content_tag("span", " *", :class => "required"): "")
    content_tag("label", label_text)
  end

  def labelled_tabular_form_for(name, object, options, &proc)
    options[:html] ||= {}
    options[:html][:class] = 'tabular' unless options[:html].has_key?(:class)
    form_for(name, object, options.merge({ :builder => TabularFormBuilder, :lang => current_language}), &proc)
  end

  def back_url_hidden_field_tag
    back_url = params[:back_url] || request.env['HTTP_REFERER']
    back_url = CGI.unescape(back_url.to_s)
    hidden_field_tag('back_url', CGI.escape(back_url)) unless back_url.blank?
  end

  def back_url
     back_url = params[:back_url] || request.env['HTTP_REFERER']
     back_url = CGI.unescape(back_url.to_s)
    CGI.escape(back_url) unless back_url.blank?
  end

  def check_all_links(form_name)
    link_to_function(l(:button_check_all), "checkAll('#{form_name}', true)") +
    " | " +
    link_to_function(l(:button_uncheck_all), "checkAll('#{form_name}', false)")
  end

  def progress_bar(pcts, options={})
    pcts = [pcts, pcts] unless pcts.is_a?(Array)
    pcts[1] = pcts[1] - pcts[0]
    pcts << (100 - pcts[1] - pcts[0])
    width = options[:width] || '100px;'
    legend = options[:legend] || ''
    content_tag('p', legend, :class => 'pourcent')+
    content_tag('table',      
      content_tag('tr',
        (pcts[0] > 0 ? content_tag('td', '', :style => "width: #{pcts[0].floor}%;", :class => 'closed') : '') +
        (pcts[1] > 0 ? content_tag('td', '', :style => "width: #{pcts[1].floor}%;", :class => 'done') : '') +
        (pcts[2] > 0 ? content_tag('td', '', :style => "width: #{pcts[2].floor}%;", :class => 'todo') : '')
      ), :class => 'progress', :style => "width: #{width};")
      
  end

  def context_menu_link(name, url, options={})
    options[:class] ||= ''
    if options.delete(:selected)
      options[:class] << ' icon-checked disabled'
      options[:disabled] = true
    end
    if options.delete(:disabled)
      options.delete(:method)
      options.delete(:confirm)
      options.delete(:onclick)
      options[:class] << ' disabled'
      url = '#'
    end
    link_to name, url, options
  end

  def calendar_for(field_id)
    include_calendar_headers_tags
    image_tag("calendar.png", {:id => "#{field_id}_trigger",:class => "calendar-trigger"}) +
    javascript_tag("Calendar.setup({inputField : '#{field_id}', ifFormat : '%Y-%m-%d', button : '#{field_id}_trigger' });")
  end

  def initialize_datepicker()
   javascript_tag(
     "jQuery().ready(function() {
        jQuery('.ui-datepicker').datepicker({
            showOn: 'button',            
            buttonImage: '/images/calendar.png',
            changeMonth: true,
            buttonImageOnly: true,
            firstDay: 1,
            dayNames: ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'],
            dayNamesMin: ['Di', 'Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa'],
            dayNamesShort: ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'],
            monthNames: ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Aout','Septembre','Octobre','Novembre','Decembre'],
            monthNamesShort: ['Jan','Fev','Mar','Avr','Mai','Jui','Jui','Aou','Sep','Oct','Nov','Dec'],
            dateFormat: 'yy-mm-dd'
            })
      });"
   )

  end


 

  def include_calendar_headers_tags
    unless @calendar_headers_tags_included
      @calendar_headers_tags_included = true
      content_for :header_tags do
        javascript_include_tag('calendar/calendar') 
        javascript_include_tag("calendar/lang/calendar-#{current_language}.js") 
        javascript_include_tag('calendar/calendar-setup') 
        stylesheet_link_tag('calendar')
      end
    end
  end

  def content_for(name, content = nil, &block)
    @has_content ||= {}
    @has_content[name] = true
    super(name, content, &block)
  end

  def has_content?(name)
    (@has_content && @has_content[name]) || false
  end

  # Returns the avatar image tag for the given +user+ if avatars are enabled
  # +user+ can be a User or a string that will be scanned for an email address (eg. 'joe <joe@foo.bar>')
  def avatar(user, options = { })
    if Setting.gravatar_enabled?
      email = nil
      if user.respond_to?(:mail)
        email = user.mail
      elsif user.to_s =~ %r{<(.+?)>}
        email = $1
      end
      return gravatar(email.to_s.downcase, options) unless email.blank? rescue nil
    end
  end


  def tree_ul(action, acts_as_tree_set, have_parent, init=true, &block)
    if acts_as_tree_set.size > 0
      if !have_parent
          ret = '<ul class="projects_children_list" style="display:none;">'
      else
          ret = '<ul class="projects_list">'
      end
      acts_as_tree_set.collect do |item|
        next if item.parent_id && init
        padding = item.level*15
        if item.send("#{action}_count") == 0
          ret += "<li style='padding-left:#{padding}px;' id='#{action}_id_#{item.id}'>"
        else
          ret += "<li style='padding-left:#{padding}px;' id='#{action}_id_#{item.id}'>"
          ret += "<img class='tree_img' src='/images/expand.png' onClick=showChildrenProject('#{action}_id_#{item.id}') />"
        end
        ret += yield item
        #ret += "#{item.children}"
        have_parent = false
        ret += tree_ul(action, item.children, have_parent, false, &block) if item.children.size > 0
        ret += '</li>'
      end
      ret += '</ul>'
    end
  end


  def init_tree_table(issues, padding, parent_class,   query)
    padding += 1
    issues.collect do |issue|
    if issue.parent_id.nil?
        ret = "<tr id='#{issue.id}' class='hascontextmenu #{cycle('even', 'odd')}'>"
        ret += '<td class="checkbox">'
        ret += "#{check_box_tag("ids[]", issue.id, false, :id => nil)}"
        ret += '<img class="tree_img" src="/images/expand.png" onClick="showChildrenIssue(' + "#{issue.id}" + ')" />' if issue.children.size > 0
        ret += "</td>"
        ret += '<td>' + "#{issue.id}" + '</td>'
        query.columns.each do |column|
          if column == query.columns.last
            td_class = "last #{column.name}"
          else
            td_class=column.name
          end
          ret += "#{content_tag 'td', column_content(column, issue), :class => td_class  }"
        end
        ret += '</tr>'
        ret += "#{init_tree_table(issue.children, 1, '', query)}"
      else
          class_tr = "#{parent_class}" + " tree_class_parent_#{issue.parent_id}"
          ret = '<tr id='"#{issue.id}"' value="' + "#{issue.parent_id}" + '" class="' + "#{class_tr}" + " hascontextmenu #{cycle('odd', 'even')}" +'" style="display:none;" >'
          ret += '<td class="checkbox" style="padding-left:' + "#{padding}" + 'em;" >'          
          ret += "#{check_box_tag("ids[]", issue.id, false, :id => nil)}"
          ret += '<img class="tree_img" src="/images/expand.png" onClick="showChildrenIssue(' + "#{issue.id}" + ')" />' if issue.children.size > 0
        
          ret += "</td>"
          ret += '<td>' + "#{issue.id}" + '</td>'
          query.columns.each do |column|
              ret += "#{content_tag 'td', column_content(column, issue), :class => column.name}"
            end
          ret += '</tr>'
          ret += "#{init_tree_table(issue.children, padding, class_tr, query) if issue.children.size > 0}"
      end
   end
  end

   # <div class="clear"></div>
  def clear_tag
     content_tag(:div, "", :class => 'clear')
  end

  # module avec titre + content
  # utilisation :
  # <% box "titre", :class => 'ma_classe' do %>
  #   contenu
  # <% end %>
  def box(title, contenu, links=[])
    if links.size>0    
      links_str = "<div class='box_links'>"
      links_str += links.join(' ')      
      links_str += "</div>"
    end

    output = content_tag(:div,
        content_tag(:div,
          content_tag(:div,title, :class=>'box_title') + "#{links_str if links_str}", :class => 'box_header') + content_tag(:div,contenu, {:class => 'box_content'}), :class=>"box")
    
  end


  def box_sidebar(title, content)
    output = content_tag(:div,
      content_tag(:div, title,:class=>"sidebar_head") + content_tag(:div, content,:class=>"sidebar_content"),:class=>"sidebar_box")
  end

  def user_thumbnail(user)
    name = content_tag(:p,(user && !user.anonymous?) ? link_to(user.name, :controller => 'account', :action => 'show', :id => user) : 'Anonymous',:class=>"name")   
    thumbnail = content_tag(:li,name,:class=>"user_thumbnail thumbnail")
  end

  def partner_thumbnail(partner,partner_project)
    unless partner.nil?
      unless partner.logo_file_name.nil?
        name = content_tag(:p,truncate(partner.name, 15),:class=>"name icon_visu", :name => partner.name)
        thumbnail = content_tag(:li,
        content_tag(:div,link_to_remote("#{image_tag('/images/delete.png')}",{:url=> project_project_partner_path(@project,partner_project),:method=>:delete,:confirm=>'Etes-vous sûr ?'}),:class=>"links_edit_box")+
        tag("img", { :src => partner.logo.url(:thumb) ,:class=>"left"}) + name, :class=>"user_thumbnail thumbnail editable_box")
      else
        name = content_tag(:p,truncate(partner.name, 15),:class=>"name icon_visu", :name => partner.name)
        thumbnail = content_tag(:li,
        content_tag(:div,link_to_remote("#{image_tag('/images/delete.png')}",{:url=> project_project_partner_path(@project,partner_project),:method=>:delete,:confirm=>'Etes-vous sûr ?'}),:class=>"links_edit_box")+
        name, :class=>"user_thumbnail thumbnail editable_box")
      end
    end
  end

  def member_thumbnail(user,member)
    name = content_tag(:p,(user && !user.anonymous?) ? link_to("#{truncate(user.name, 15)}", account_path(user), :class => "icon_visu", :name=>"#{user.name}") : 'Anonymous',:class=>"name")
    role = content_tag(:p, "#{truncate(user.role_for_project(@project).name, 20)}",:class=>"role_user icon_visu", :name => "#{user.role_for_project(@project).name}")
    thumbnail = content_tag(:li,
      content_tag(:div,link_to_remote("#{image_tag('/images/delete.png')}",{:url=> project_member_path(@project,member) ,:method=>:delete,:confirm=>'Etes-vous sûr ?'}),:class=>"links_edit_box")+
      name+role,:class=>"user_thumbnail thumbnail editable_box")
  end


  def file_thumbnail(file)   
      link =  content_tag(:div,link_to_remote("#{image_tag('/images/delete.png')}",{:url=>"/file_attachments/destroy/#{file.id}",:confirm=>'Etes-vous sûr ?'}),:class=>"links_edit_box")
   

    title = link_to_attachment file, :download => true, :title => file.description
   #  title = link_to(content_tag(:p,file.filename,:class=>"filename"), {:controller => 'versions', :action => 'show', :id => file})
   
    author = author.nil? ? "" : content_tag(:p,file.author.name,:class=>"author")
    created_on = content_tag(:p,format_time(file.created_on),:class=>"created_on")
    thumbnail = content_tag(:li,
     link+
      content_tag(:div,title+author+created_on,:class=>"thumbnail_infos"),:class=>"file_thumbnail thumbnail editable_box",:name=>"#{file.file_file_name}")

  end

  def grey_box(box_content, box_class)
    output = content_tag(:div,box_content,:class=>box_class+" grey_box")
  end

  def grey_title(title)
    output = content_tag(:div,title,:class=>"grey_title")
  end

  def initialize_icons_tooltip()
    html = "#{javascript_include_tag("jquery/jquery.tooltip.js")}"
    html += "#{javascript_tag("jQuery().ready(function() {jQuery('.icon_visu').tooltip({bodyHandler: function() {return jQuery(this).attr('name');},showURL: false })});")}"
  end

  def profile_project_box(title,content)
    link = link_to_remote "#{image_tag('/images/edit.png')}",
                         { :url => { :controller => 'projects', :action => 'edit_part_profile', :project_id => @project.id},
                           :method => 'get',
                           :update=>'project-form',
                           :with=>'toggle_profile()'
                         }
#    link= "#{toggle_link image_tag("/images/edit.png"), 'update-profile-form',{:second_element=>"infos_project"}}"
    content_tag(:div,
      content_tag(:div,content_tag(:div,title,:class=>"left",:style=>"max-width:90%;")+content_tag(:div,link,:class=>"links_edit_box")+content_tag(:div,"",:class=>"clearer"),:class=>'profile_header')+
      content_tag(:div,content,:class=>'profile_content'),:class=>"profile editable_box",:style=>"max-width:100%;")
  end

  def profile_box(title,content)    
    content_tag(:div,
      content_tag(:div,content_tag(:div,title,:class=>"left",:style=>"max-width:90%;")+content_tag(:div,"",:class=>"clearer"),:class=>'profile_header')+
      content_tag(:div,content,:class=>'profile_content'),:class=>"profile",:style=>"max-width:100%;")
  end


   def form_upload(args)
    
    name_div_id=args[:name_div_id] || "div_upload_form"
    url=args[:url]
    textarea_id=args[:textarea_id] || ""
    textarea_class=args[:textarea_class] || ""
    col_collection=args[:col_collection]
    item_id=col_collection.id.to_s || args[:item_id].to_s
    name_initial_form=args[:name_initial_form].to_s || "initial_form"

    if textarea_id==""
      data_textarea=""
    else
      data_textarea="$('##{textarea_id}').val(tinyMCE.get('#{textarea_id}').getContent());$('#'+formId+' .#{textarea_class}').val($('##{name_initial_form} .#{textarea_class}').val());"
    end
    concat_url = url+item_id
   
    data=<<-END
    <script> 
        function clone_#{name_div_id}_form(){
        jQuery.ajaxFileUpload({url:'#{concat_url}',
        secureuri:false, fileElementId:'fileToUpload', dataType: 'json',     
        before_send_callback:function(formId){
          jQuery('##{name_initial_form}:input').clone().appendTo(jQuery('#'+formId));
          #{data_textarea}
        }
      });return true;
      };

    </script>
    <div id="#{name_div_id}" style="display:none">
    #{form_tag url+item_id,:method => :post, :enctype=>"multipart/form-data", :target=>"upload_frame",:id=>"form_"+name_div_id }
       <div id="inner_form_#{name_div_id}"></div>
       #{submit_tag l(:button_validate)}
    </form>
    </div>
   END
  end

   def current_project
     session[:project]
   end

   def display_message_error(my_collection, type)
     line_js ="<ul>";
    if my_collection.class==String
      line_js +="<li>#{l("#{my_collection}")}</li>";
    else
      my_collection.errors.each{|attr,msg| line_js += "<li>- #{l("label_#{attr}")} #{l("#{msg}")}</li>" }

    end
    line_js += "</ul>"
    line_js="jQuery('#errorExplanation').html(\"#{line_js}\");
            jQuery('#errorExplanation').show();
            setTimeout(function() {
                jQuery('#errorExplanation').slideUp();
            }, 10000);
            jQuery('#errorExplanation').attr('class', '" + type + "')
     "
    return line_js  # envoi de line_js
   end


  private

  def wiki_helper
    helper = Redmine::WikiFormatting.helper_for(Setting.text_formatting)
    extend helper
    return self
  end
end

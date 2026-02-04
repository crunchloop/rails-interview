module ApplicationHelper
  def icon(name, **opts)
    opts[:data] ||= {}
    opts[:data][:lucide] = name

    tag.i(**opts)
  end
end

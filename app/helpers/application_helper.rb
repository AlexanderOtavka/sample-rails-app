module ApplicationHelper
  def title(page_title = "")
    base_title = "PrettyPics"

    if not page_title.empty?
      "#{page_title} | #{base_title}"
    else
      base_title
    end
  end
end

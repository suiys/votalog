module ApplicationHelper
  DEFAULT_TITLE = "Votalog".freeze

  def display_page_title(page_title)
    if page_title.blank?
      DEFAULT_TITLE
    else
      page_title + " | " + DEFAULT_TITLE
    end
  end
end

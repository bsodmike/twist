module ElementsHelper
  def render_elements(elements)
    elements.each do |element|
      concat(render_element(element))
    end
    nil
  end
  
  def render_element(element)
    partial = find_element_partial(element) ? element.tag : "element"
    render(:partial => "elements/#{partial}", :locals => { :element => element })
  end
  
  def render_footnote(element)
    @footnote_count ||= 0
    @footnote_count += 1
    footnote = Nokogiri::HTML(element.content)
    # TODO: Work out a better way to style the whole footnote container
    content_tag("span", :class => "footnote_container") do
      "<a name='footnote_#{@footnote_count}'></a><sup>fn #{@footnote_count}</sup> #{footnote.to_html}<br />".html_safe
    end
  end
  
  def render_image(element)
    figure_html = Nokogiri::HTML(element.content)
    content_tag(:div, :class => "figure") do
      raw("<img src='/figures/#{element.book.id}/#{figure_html.css("img")[0]["src"]}' /><br>") +
      raw(figure_html.css("span.title").to_html)
    end
  end
  
  private

  def find_element_partial(element)
    @partials ||= {}
    return @partials[element.tag] unless @partials[element.tag].nil?
    partial = Rails.root + "app/views/elements/_#{element.tag}.html.erb"
    @partials[element.tag] = File.exist?(partial)
  end
end

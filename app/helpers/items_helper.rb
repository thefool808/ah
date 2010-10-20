module ItemsHelper
  def large_icon(item)
    image_tag "http://static.wowhead.com/images/wow/icons/large/#{item.icon}.jpg"
  end

  def wowhead_item_link(item)
    link_to item.name, "http://www.wowhead.com/?item=#{item.item_id}", :target => "_BLANK"
  end

  # def line_chart(name, data)
  # end
end

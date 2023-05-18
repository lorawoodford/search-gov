require 'wcag_color_contrast'

module AffiliateCssHelper
  def color_picker_component(form, property, css_property_hash, data)
    data[:color] = site_css_color_property(css_property_hash, property)
    data[:provide] = 'colorpicker'
    data['default-color'] = Affiliate::THEMES[:default][property]

    value = css_property_hash[property]
    value ||= Affiliate::THEMES[:default][property]
    inner_html = content_tag :div do
      form.text_field property, value: value
    end

    inner_html << content_tag(:span, class: 'add-on add-on-colorpicker') do
      content_tag :i
    end

    content_tag(:div, class: 'input-append color', data: data) { inner_html }
  end

  def contrast_checker(css_property_hash, my_color, their_color)
    my_color_value = css_property_hash[my_color]&.delete('#')
    their_color_value = css_property_hash[their_color] ? css_property_hash[their_color]&.delete('#') : their_color
    ratio = format('%.2f', WCAGColorContrast.ratio(my_color_value, their_color_value))
    icon = ratio.to_i >= 4.5 ? "\u2705" : "\u274C"
    "#{icon} Contrast is #{ratio} between #{my_color.to_s.tr('_', ' ')} and #{their_color.to_s.tr('_', ' ')}"
  end

  def render_affiliate_css_property_value(css_property_hash, property)
    case property.to_s
      when /color/i
        site_css_color_property(css_property_hash, property)
      when /font_family/i
        FontFamily.get_css_property_value css_property_hash[property]
      else
        property_value = css_property_hash[property]
        property_value.blank? ? Affiliate::DEFAULT_CSS_PROPERTIES[property] : property_value
    end
  end
  alias_method :site_css_property, :render_affiliate_css_property_value

  def site_css_color_property(css_property_hash, property)
    value = css_property_hash[property]
    value =~ /^#([0-9A-F]{3}|[0-9A-F]{6})$/i ? value : Affiliate::DEFAULT_CSS_PROPERTIES[property]
  end

  def header_tagline_font_family(css_property_hash)
    css_property_hash[:header_tagline_font_family] || HeaderTaglineFontFamily::DEFAULT
  end
end

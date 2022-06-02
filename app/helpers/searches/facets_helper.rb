# frozen_string_literal: true

module Searches::FacetsHelper
  def tag_facet(search, search_params)
    html = []
    html << tag_facet_html(search, search_params)

    render partial: 'searches/i14y/facets', locals: { html: html.join("\n") }
  end

  def tag_facet_html(search, search_params)
    path = path_for_filterable_search(search,
                                      search_params,
                                      build_facet_options[:extra_params])

    link_to(build_facet_options[:extra_params].first, path)
  end

  def build_facet_options
    {
      extra_params: { tags: 'immigration' }
    }
  end

  def clear_facet(search, search_params)
    path = path_for_filterable_search(search,
                                      search_params,
                                      {})

    link_to("Clear", path)
  end
end

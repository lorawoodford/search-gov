# frozen_string_literal: true

module Searches::FacetsHelper
  def tag_facet(search, search_params)
    html = []
    html << tag_facet_html(search, search_params)

    render partial: 'searches/i14y/facets', locals: { html: html.join("\n") }
  end

  def tag_facet_html(search, search_params)
    search.aggregation.map do |a|
      html = []
      html << link_to(a.to_hash['key'],
                      facet_path(search, search_params, a.to_hash['key']))
      html << content_tag(:span, "(#{a.to_hash['doc_count']})")
      html << tag.br
    end
  end

  def facet_path(search, search_params, facet)
    path_for_filterable_search(search,
                               search_params,
                               { tags: facet })
  end

  def clear_facet(search, search_params)
    path = path_for_filterable_search(search,
                                      search_params,
                                      {})

    link_to('Clear', path)
  end
end

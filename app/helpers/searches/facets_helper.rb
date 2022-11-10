# frozen_string_literal: true

# NOTE: This is very much a WIP and merely written so that there is a rudimentary UI to review during ongoing
# backend faceted search work.
module Searches::FacetsHelper
  def facet(search, search_params)
    html = []
    html << facet_html(search, search_params)

    render partial: 'searches/i14y/facets', locals: { html: html.join("\n") }
  end

  def facet_html(search, search_params)
    return unless search.aggregations

    search.aggregations.map do |agg|
      html = []
      html << content_tag(:h3, agg.first.first)
      html << row_html(search, search_params, agg)
      html << tag.br
      html << clear_facet(search, search_params)
    end
  end

  def row_html(search, search_params, agg)
    if agg.first.last.filter_map(&:to_as_string).present? || agg.first.last.filter_map(&:from_as_string).present?
      agg.first.last.map do |r|
        "#{link_to(r.agg_key, date_facet_path(search, search_params, agg.first.first, r.from_as_string, r.to_as_string))} (#{r.doc_count})"
      end
    else
      agg.first.last.map do |r|
        "#{link_to(r.agg_key, facet_path(search, search_params, agg.first.first, r.agg_key))} (#{r.doc_count})"
      end
    end
  end

  def date_facet_path(search, search_params, field, from, to)
    path_for_filterable_search(search,
                               search_params,
                               { since_date: from,
                                 until_date: to })
  end

  def facet_path(search, search_params, field, facet)
    path_for_filterable_search(search,
                               search_params,
                               { "#{field}": facet })
  end

  def clear_facet(search, search_params)
    path = path_for_filterable_search(search,
                                      search_params,
                                      { clear_params: true })

    link_to('Clear', path)
  end
end

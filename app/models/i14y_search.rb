class I14ySearch < FilterableSearch
  include SearchInitializer
  include Govboxable
  I14Y_SUCCESS = 200
  attr_reader :collection, :matching_site_limits

  def initialize(options = {})
    super
    @enable_highlighting = !(false === options[:enable_highlighting])
    @collection = options[:document_collection]
    @site_limits = options[:site_limits]
    @matching_site_limits = formatted_query_instance.matching_site_limits
  end

  def search
    search_options = {
      handles: handles,
      language: @affiliate.locale,
      query: formatted_query,
      size: detect_size,
      offset: detect_offset,
    }.merge!(filter_options).
      merge!(facet_options)

    I14yCollections.search(search_options)
  rescue Faraday::ClientError => e
    Rails.logger.error "I14y search problem: #{e.message}"
    false
  end

  def filter_options
    filter_options = { }
    filter_options[:sort_by_date] = 1 if @sort_by == 'date'
    filter_options[:min_timestamp] = @since if @since
    filter_options[:max_timestamp] = @until if @until
    filter_options[:ignore_tags] = @affiliate.tag_filters.excluded.pluck(:tag).sort.join(',') if @affiliate.tag_filters.excluded.present?
    filter_options[:tags] = @affiliate.tag_filters.required.pluck(:tag).sort.join(',') if @affiliate.tag_filters.required.present?
    filter_options
  end

  def facet_options
    facet_options = { }
    facet_options[:tags] = @options[:tags] if !@options[:tags].nil?
    facet_options
  end

  def detect_size
    @limit ? @limit : @per_page
  end

  def detect_offset
    @offset ? @offset : ((@page - 1) * @per_page)
  end

  def first_page?
    @offset ? @offset.zero? : super
  end

  def aggregation
    @aggregation ? @aggregation : nil
  end

  protected

  def handles
    handles = []
    handles += @affiliate.i14y_drawers.pluck(:handle) if @affiliate.gets_i14y_results
    handles << 'searchgov' if affiliate.search_engine == 'SearchGov' || !(@affiliate.gets_i14y_results)
    handles.join(',')
  end

  def handle_response(response)
    if response && response.status == I14Y_SUCCESS
      @total = response.metadata.total
      I14yPostProcessor.new(@enable_highlighting,
                            response.results,
                            @affiliate.excluded_urls_set).post_process_results
      @results = paginate(response.results)
      @startrecord = ((@page - 1) * @per_page) + 1
      @endrecord = @startrecord + @results.size - 1
      @spelling_suggestion = response.metadata.suggestion.text if response.metadata.suggestion.present?
      @aggregation = response.metadata.aggregation if response.metadata.aggregation.present?
    end
  end

  def populate_additional_results
    @govbox_set = GovboxSet.new(query, affiliate, @options[:geoip_info], @highlight_options) if first_page?
  end


  def log_serp_impressions
    @modules |= @govbox_set.modules if @govbox_set
    @modules << 'I14Y' if @total > 0
  end

  def domains_scope_options
    DomainScopeOptionsBuilder.build(site: @affiliate,
                                    collection: collection,
                                    site_limits: @site_limits)
  end

  def formatted_query
    formatted_query_instance.query
  end

  def formatted_query_instance
    @formatted_query_instance ||= I14yFormattedQuery.new(@query, domains_scope_options)
  end
end

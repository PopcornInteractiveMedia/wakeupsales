  class SourcesDatatable
  include ApplicationHelper
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: sources_info(params[:org]).count,
      iTotalDisplayRecords: sources.total_entries,
      aaData: data
    }
  end

private

  def sources_info(org)
    Source.source_list(org)
  end

  def data
    sources.map do |source|
      [
        h(source.id),
        h(source.name)
      ]
    end
  end
  
  def sources
    @sources ||= fetch_sources
  end

  def fetch_sources
    sources = sources_info(params[:org])
    sources = sources.page(page).per_page(per_page)
    if params[:sSearch].present?
      sources = sources.where("(name like :search)", search: "%#{params[:sSearch]}%")
    end
    sources
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[title]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end

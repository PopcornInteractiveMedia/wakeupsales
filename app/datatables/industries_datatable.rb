  class IndustriesDatatable
  include ApplicationHelper
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: industries_info(params[:org]).count,
      iTotalDisplayRecords: industries.total_entries,
      aaData: data
    }
  end

private

  def industries_info(org)
    Industry.industry_list(org)
  end

  def data
    industries.map do |industry|
      [
        h(industry.id),
        h(industry.name)
      ]
    end
  end
  
  def industries
    @sources ||= fetch_industries
  end

  def fetch_industries
    industries = industries_info(params[:org])
    industries = industries.page(page).per_page(per_page)
    if params[:sSearch].present?
      industries = industries.where("(name like :search)", search: "%#{params[:sSearch]}%")
    end
    industries
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

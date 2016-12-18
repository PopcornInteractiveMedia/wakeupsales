class ReportsController < ApplicationController

# /****************************************************************************************
#WakeupSales Community Edition is a web based CRM developed by WakeupSales. Copyright (C) 2015-2016

#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation with the addition of the following permission added to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program; if not, see http://www.gnu.org/licenses or write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#You can contact WakeupSales, 2059 Camden Ave. #118, San Jose, CA - 95124, US.  or at email address support@wakeupsales.org.

#The interactive user interfaces in modified source and object code versions of this program must display Appropriate Legal Notices, as required under Section 5 of the GNU General Public License version 3.

#In accordance with Section 7(b) of the GNU General Public License version 3, these Appropriate Legal Notices must retain the display of the "Powered by WakeupSales" logo. If the display of the logo is not reasonably feasible for technical reasons, the Appropriate Legal Notices must display the words "Powered by WakeupSales".

#*****************************************************************************************/

  include HomeHelper
  include ApplicationHelper #FIXME AMT
  include ReportsHelper

  before_filter  :authenticate_admin

  layout 'report' , :only => [:report_pdf]

  def index
      ##Know the current quarter
     @current_quarter =  quarter_month_numbers Date.today
     @curr = "#{@current_quarter[0]}-#{Time.zone.now.year}"
     @quarter = @current_quarter[0].to_i
     @year = Time.zone.now.year
     if(@current_quarter == [1])
        @start_date = DateTime.new(Time.zone.now.year,1,1)
        @end_date = DateTime.new(Time.zone.now.year,3,31)
      elsif(@current_quarter == [2])
        @start_date = DateTime.new(Time.zone.now.year,4,1)
        @end_date = DateTime.new(Time.zone.now.year,6,30)
      elsif(@current_quarter == [3])
        @start_date = DateTime.new(Time.zone.now.year,7,1)
        @end_date = DateTime.new(Time.zone.now.year,9,30)
      elsif(@current_quarter == [4])
       @start_date = DateTime.new(Time.zone.now.year,10,1)
       @end_date = DateTime.new(Time.zone.now.year,12,31)
      end

#     @users = current_user.organization.users.includes(:user_role).where("users.admin_type not IN (?) ", [1,2]).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|
     @users = current_user.organization.users.includes(:user_role).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|

     t = get_user_activity_count_for_leaderboard user, @start_date, @end_date
     t t

     }
    @users = @users.reverse

  end


  def get_funnel_chart
    get_start_end_date = get_start_date_and_end_date(params[:quarter])
    start_date = get_start_end_date[0]
    end_date = get_start_end_date[1]
    #deals_funnel_chart=Deal.includes(:deal_status).where("deals.deal_status_id IS NOT NULL").by_range(start_date,end_date).by_is_active.group("deal_statuses.original_id").count

    deals_funnel_chart=Deal.includes(:deal_status).where(:organization_id=>@current_organization.id).where("deals.deal_status_id IS NOT NULL").by_is_active.by_range(start_date,end_date).group("deal_statuses.original_id").count



    @new_deals = (wd=deals_funnel_chart.values_at(1).first).present? ? wd : 0
#    @qualified_deals = get_deal_status_count_within_four_weeks([2]).by_range(start_date,end_date).count
#    @lost_deals = get_deal_status_count_within_four_weeks([5]).by_range(start_date,end_date).count
#    @won_deals = get_deal_status_count_within_four_weeks([4]).by_range(start_date,end_date).count


    @qualified_deals=(wd=deals_funnel_chart.values_at(2).first).present? ? wd : 0
    @lost_deals=(ld=deals_funnel_chart.values_at(5).first).present? ? ld : 0
    @won_deals=(wd=deals_funnel_chart.values_at(4).first).present? ? wd : 0
    #Funnel chart by quarterly
    @funnel_chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.chart({ type: 'funnel', marginRight: 70})
      #f.title({ text: 'Sales funnel', x: -50})
      f.colors([ '#336699','#263c53', '#aa1919', '#8bbc21'])
      f.plotOptions(
        series: {
          dataLabels: {
              enabled: true,
              format: '<b>{point.name}</b> ({point.y:,.0f})',
              color: 'black',
              softConnector: true
          },
          neckWidth: '10%',
          neckHeight: '-10%',
          height: '90%',

      })
      f.legend( { enabled: true })
      f.series({
        name: 'no',
        data: [
              ['New Deals (' + @new_deals.to_s + ')' ,  @new_deals],
              ['Qualified Deals (' + @qualified_deals.to_s + ')' ,  @qualified_deals],
              ['Lost Deals (' + @lost_deals.to_s + ')' , @lost_deals],
              ['Won Deals (' + @won_deals.to_s + ')' , @won_deals]
            ]
       })
      end

     render :partial => "sales_funnel_chart"


  end

  def pie_tag_chart
    begin
    get_start_end_date = get_start_date_and_end_date(params[:quarter])
    @start_date = get_start_end_date[0].strftime('%Y-%m-%d')
    @end_date = get_start_end_date[1].strftime('%Y-%m-%d')
      @tag_datatable =  ActiveRecord::Base.connection.execute("Select tags.name as tag_name, Count(deals.id) as count,deal_statuses.name as deal_status,deal_status_id from deals inner join taggings,tags,deal_statuses where deals.organization_id = #{@current_organization.id} and deals.id = taggings.taggable_id and  deals.is_active=1 and deals.created_at between '#{@start_date}' and '#{@end_date}' and taggings.taggable_type='Deal' and tags.id = taggings.tag_id and deal_statuses.id = deals.deal_status_id Group by tag_id,deal_status_id,tags.name")
      @technologylist =  ActiveRecord::Base.connection.execute("Select tags.name as tag_name, Count(deals.id) as count from deals inner join taggings,tags,deal_statuses  where deals.organization_id = #{@current_organization.id} and deals.id = taggings.taggable_id and  deals.is_active=1 and deals.created_at between '#{@start_date}' and '#{@end_date}' and taggings.taggable_type='Deal' and tags.id = taggings.tag_id and deal_statuses.id = deals.deal_status_id Group by tag_id,tags.name order by count desc LIMIT 10")
      technology = []
      counts = []
      @technologylist.each do |d|
          technology << d[0]
      end
      technology = technology
      new_deals=[]
      qualified_deals=[]
      notqualified_deals=[]
      won_deals=[]
      lost_deals=[]
      junk_deals=[]
      technology.each do |tech|
        newd = @tag_datatable.select{|hash| hash[3] == @current_organization.incoming_deal_status().id && hash[0] == tech }
        qualifyd = @tag_datatable.select{|hash| hash[3] == @current_organization.qualify_deal_status().id && hash[0] == tech }
        notqualifyd = @tag_datatable.select{|hash| hash[3] == @current_organization.not_qualify_deal_status().id && hash[0] == tech }
        wond = @tag_datatable.select{|hash| hash[3] == @current_organization.won_deal_status().id && hash[0] == tech }
        lostd = @tag_datatable.select{|hash| hash[3] == @current_organization.lost_deal_status().id && hash[0] == tech }
        junkd = @tag_datatable.select{|hash| hash[3] == @current_organization.junk_deal_status().id && hash[0] == tech }
        new_deals << (!newd.present? ? 0 : newd[0][1])
        qualified_deals << (!qualifyd.present? ? 0 : qualifyd[0][1])
        notqualified_deals << (!notqualifyd.present? ? 0 : notqualifyd[0][1])
        won_deals << (!wond.present? ? 0 : wond[0][1])
        lost_deals << (!lostd.present? ? 0 : lostd[0][1])
        junk_deals << (!junkd.present? ? 0 : junkd[0][1])
      end
      if @current_user.is_admin?
        @pie_tag_chart  = LazyHighCharts::HighChart.new('bar') do |f|
          f.xAxis({categories: technology,title: {text: "Tags"}})
          f.series(:name=>"New Deals",:data=> new_deals)
          f.series(:name=>'Qualified',:data=> qualified_deals)
          f.series(:name=>'Lost',:data=> lost_deals)
          f.series(:name=>'Won',:data=> won_deals )
          f.series(:name=>'Not Qualified',:data=> notqualified_deals)
          f.series(:name=>'Junk',:data=> junk_deals)
                f.colors([ '#336699','#263c53', '#aa1919', '#8bbc21','#FF3300', '#E74B3B' ])
                 f.title({ :text=>""})
                 f.legend({verticalAlign: 'bottom',
                          backgroundColor: 'white',
                          borderColor: '#CCC',
                          borderWidth: 1,
                          shadow: false
                      })
                f.options[:chart][:defaultSeriesType] = "bar"
                f.plot_options({:bar=>{:stacking=>"normal"}})
               end ## do end
            end #if end
    rescue
      @pie_tag_chart  = LazyHighCharts::HighChart.new('bar')
    ensure
     render partial: "pie_tag_chart"
    end
  end


  def get_user_list_leaderboard
    get_start_end_date = get_start_date_and_end_date(params[:quarter])
    @start_date = get_start_end_date[0]
    @end_date = get_start_end_date[1]
    #  @users = current_user.organization.users.includes(:user_role).where("users.admin_type not IN (?) ", [1,2]).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|

    # t = get_user_activity_count_for_leaderboard user, @start_date, @end_date
    # t t

    # }

     @users = current_user.organization.users.includes(:user_role).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|

     t = get_user_activity_count_for_leaderboard user, @start_date, @end_date
     t t

     }
    @users = @users.reverse
     render :partial => "leaderboard_list"
  end


  def get_deals_won
    get_start_end_date = get_start_date_and_end_date(params[:quarter])
    @start_date = get_start_end_date[0]
    @end_date = get_start_end_date[1]
    @deals ||= get_deal_status_total_won([4],@start_date,@end_date) if @start_date.present? && @end_date.present?

    #SELECT COUNT(DISTINCT `deals`.`id`) FROM `deals` LEFT OUTER JOIN `deal_statuses` ON `deal_statuses`.`id` = `deals`.`deal_status_id` WHERE `deals`.`organization_id` = 1 AND (`deals`.`created_at` BETWEEN '2012-04-01 00:00:00' AND '2012-06-30 00:00:00') AND (deal_statuses.original_id IN (4) )
    render :partial => "deals_won_list"
  end

  def get_start_date_and_end_date quarter
      data=quarter.split("-")
      @curr = "#{data[0].to_i}-#{data[1].to_i}"
      @quarter = data[0].to_i
      @year = data[1].to_i
      case data[0]
      when "1"
        @start_date = DateTime.new(data[1].to_i,1,1)
        @end_date = DateTime.new(data[1].to_i,3,31)
      when "2"
        @start_date = DateTime.new(data[1].to_i,4,1)
        @end_date = DateTime.new(data[1].to_i,6,30)
      when "3"
        @start_date = DateTime.new(data[1].to_i,7,1)
        @end_date = DateTime.new(data[1].to_i,9,30)
      when "4"
         @start_date = DateTime.new(data[1].to_i,10,1)
         @end_date = DateTime.new(data[1].to_i,12,31)
      when "Past Week"
         @start_date = 1.week.ago.beginning_of_week
         @end_date = 1.week.ago.end_of_week
      when "Past Month"
         @start_date = 1.month.ago.beginning_of_month
         @end_date = 1.month.ago.end_of_month
      end
  return @start_date, @end_date
  end

  def report_pdf
     get_start_end_date = get_start_date_and_end_date(params[:quarter])
     @start_date = get_start_end_date[0]
     @end_date = get_start_end_date[1]
     if params[:url] == "get_leads_won"
      @deals ||= get_deal_status_total_won([4],@start_date,@end_date) if @start_date.present? && @end_date.present?
     elsif params[:url] == "get_user_list_leaderboard"
      @users = current_user.organization.users.includes(:user_role).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|
       t = get_user_activity_count_for_leaderboard user, @start_date, @end_date
       t t
       }
      @users = @users.reverse
     elsif params[:url] == "get_sales_analytic"
       @users = current_user.organization.users.includes(:user_role).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|
       t = get_user_activity_count_for_leaderboard user, @start_date, @end_date
       t t
       }
       @users = @users.reverse
     end
  end
def get_sales_analytic
    get_start_end_date = get_start_date_and_end_date(params[:quarter])
    @start_date = get_start_end_date[0]
    @end_date = get_start_end_date[1]
    #  @users = current_user.organization.users.includes(:user_role).where("users.admin_type not IN (?) ", [1,2]).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|

    # t = get_user_activity_count_for_leaderboard user, @start_date, @end_date
    # t t

    # }

     @users = current_user.organization.users.includes(:user_role).where("is_active =?", true).order("users.admin_type, user_roles.role_id").sort_by { |user| get_deal_status_won_count(user,[4],@start_date,@end_date).count }.sort_by { |user|

     t = get_user_activity_count_for_leaderboard user, @start_date, @end_date
     t t

     }
    @users = @users.reverse
     render :partial => "sales_analytic"
  end
  def lead_age_bar_chart

   begin
       lead_arr = []
       new_deal_piedonut=Deal.includes(:deal_status).where("deals.deal_status_id IS NOT NULL").where(deal_status_count_last_one_month(params[:quarter])).group("deal_statuses.original_id").count
     #  new_chart = new_deal_piedonut.values.sum
    #   q_piedonut=new_deal_piedonut.values_at(2).first
    #   l_piedonut=new_deal_piedonut.values_at(5).first
    #   w_piedonut=new_deal_piedonut.values_at(4).first


       dealstages = []
        stagecounts = []
      @current_user.organization.deal_statuses.each do |status|
        dealstages << status.name
        stagecounts << new_deal_piedonut.values_at(status.original_id).first
      end


       puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"

      if @current_user.is_admin?
       puts "&&&&&&&&&&&&&&&&&********************"
        @bar_tag_chart  = LazyHighCharts::HighChart.new('bar') do |f|
          #f.xAxis({categories: ['New Deals','Qualified','Lost','Won'],title: {text: "Deal Stages"}})
         # f.series(:data=> [new_chart,q_piedonut,l_piedonut,w_piedonut],:name=>'Total')
         f.xAxis({categories: dealstages,title: {text: "Deal Stages"}})
         f.series(:data=>stagecounts,:name=>'Total')
          # f.series(:name=>'Qualified',:data=> [10])
          # f.series(:name=>'Lost',:data=> [10])
          # f.series(:name=>'Won',:data=> [10] )
          # f.series(:name=>'Not Qualified',:data=> [10]) 
          # f.series(:name=>'Junk',:data=> [10])

                 f.title({ :text=>""})
                 f.legend({verticalAlign: 'bottom',
                          backgroundColor: 'white',
                          borderColor: '#CCC',
                          borderWidth: 1,
                          shadow: false
                      })
                f.options[:chart][:defaultSeriesType] = "bar"
                f.plot_options({:bar=>{:stacking=>"normal"},:colorByPoint=> true})
               end ## do end
            end #if end
    rescue
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!"
      @bar_tag_chart  = LazyHighCharts::HighChart.new('bar')
    ensure
     render partial: "lead_age_bar_chart"
    end
  end

  def get_lead_report
    puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

    begin
      new_deal_piedonut=Deal.includes(:deal_status).where("deals.deal_status_id IS NOT NULL").where(deal_status_count_last_one_month(params[:lead_range])).group("deal_statuses.original_id").count

     # q_piedonut=new_deal_piedonut.values_at(2).first
     # l_piedonut=new_deal_piedonut.values_at(5).first
    #  w_piedonut=new_deal_piedonut.values_at(4).first

      new_array = []
      @current_user.organization.deal_statuses.each do |status|
        dealhash = []
        dealhash << status.name
        dealhash << new_deal_piedonut.values_at(status.original_id).first
        new_array.push dealhash
      end

      puts "----------> <----------"
      p new_array

#dfgdfgdfg
        @piedonut_chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.chart({ type: 'pie', height:282})
        #f.colors([ '#336699','#263c53', '#aa1919', '#8bbc21'])
        f.colors([ '#3497DB', '#F39C11','#2DCC70', '#E74B3C' ])
		f.title({ text: ''})
        f.plotOptions({
          pie: { shadow: false}
        })
        f.series({
          name: 'Total:',
          data:
          #[
            #    ['New',    new_deal_piedonut.values.sum],
            #    ['Qualified',     (q_piedonut.nil? ? 0 : q_piedonut)],
		#		['Won',     (w_piedonut.nil? ? 0 : w_piedonut)],
           #     ['Lost',    (l_piedonut.nil? ? 0 : l_piedonut)]

            # ],
            new_array,
          size: '60%',
          innerSize: '20%',
          showInLegend:true,
          innerSize: '20%',
          showInLegend: true
         })
          f.legend({verticalAlign: 'bottom',
                      backgroundColor: 'white',
                      borderColor: '#CCC',
                      borderWidth: 1,
                      shadow: false
                  })
        end
    rescue
      @piedonut_chart = LazyHighCharts::HighChart.new('column')
   ensure
      render :partial => "lead_report"
    end

  end

end

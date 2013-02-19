class Spree::StaticContentController < Spree::BaseController
  before_filter  :authenticate_user!, :if => :authentication_required?
  caches_action :show, :cache_path => Proc.new { |controller|
    "spree_static_content/" + controller.params[:path].to_s + "_spree_static_content"
  }
  
  layout :determine_layout
  
  def show
    page = get_page
    unless page
      render_404
    end
  end

  def authentication_required?
    page = get_page
    return false unless page
    return page.authentication_required?
  end

  private

  def get_page
    path = case params[:path]
             when Array
               '/' + params[:path].join("/")
             when String
               '/' + params[:path]
             when nil
               request.path
           end

    path = path.gsub('//','/')
    path = StaticPage::remove_spree_mount_point(path) unless Rails.application.routes.url_helpers.spree_path == "/"

    return Spree::Page.visible.find_by_slug(path)
  end

  def determine_layout
    return @page.layout if @page and @page.layout.present?
    'spree/layouts/spree_application'
  end

  def accurate_title
    @page ? (@page.meta_title.present? ? @page.meta_title : @page.title) : nil
  end
end


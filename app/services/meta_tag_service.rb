# nice use of service objects! 
class MetaTagService
  def self.defaults
    {
      site: "The Efficient Birder",
      image: ActionController::Base.helpers.asset_url('logo1.png'),
      description: "An easy way to identify birds",
      og: {
        title: "The Efficient Birder",
        image: ActionController::Base.helpers.asset_url('logo1.png'),
        description: "An easy way to identify birds",
        site_name: "The Efficient Birder"
      }
    }
  end
end

# name: discourse-vk-auth
# about: Authenticate with vk.com, see more at: https://vk.com/developers.php?id=-1_37230422&s=1
# version: 0.1
# author: pmusaraj
# url: https://github.com/discourse/discourse-vk-auth

enabled_site_setting :vk_login_enabled
enabled_site_setting :vk_client_id
enabled_site_setting :vk_client_secret

gem 'omniauth-vkontakte', '1.5.0'

register_svg_icon "fab fa-vk" if respond_to?(:register_svg_icon)

class Auth::VkontakteAuthenticator < Auth::ManagedAuthenticator

  def name
    "vkontakte"
  end

  def enabled?
    SiteSetting.vk_login_enabled
  end

  def register_middleware(omniauth)
    omniauth.provider :vkontakte,
           setup: lambda { |env|
             strategy = env["omniauth.strategy"]
              strategy.options[:client_id] = SiteSetting.vk_client_id
              strategy.options[:client_secret] = SiteSetting.vk_client_secret
           }
  end

  def description_for_user(user)
    info = UserAssociatedAccount.find_by(provider_name: name, user_id: user.id)&.info
    return "" if info.nil?

    info["name"] || ""
  end

  def after_authenticate(auth_token, existing_account: nil)
    # Ignore extra data (we don't need it)
    auth_token[:extra] = {}
    super
  end
end

auth_provider frame_width: 920,
              frame_height: 800,
              authenticator: Auth::VkontakteAuthenticator.new

register_css <<CSS
.btn-social.vkontakte {
  background: #46698f;
}
CSS

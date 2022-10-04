# frozen_string_literal: true

# The DanbooruLogger class handles logging messages to the Rails log and to NewRelic.
#
# @see https://guides.rubyonrails.org/debugging_rails_applications.html#the-logger
class DanbooruLogger
  HEADERS = %w[referer sec-fetch-dest sec-fetch-mode sec-fetch-site sec-fetch-user]

  # Log a message to the Rails log and to NewRelic.
  #
  # @param message [String] the message to log
  # @param params [Hash] optional key-value data to log with the message
  def self.info(message, params = {})
    Rails.logger.info(message)

    if defined?(::NewRelic)
      params = flatten_hash(params).symbolize_keys
      ::NewRelic::Agent.record_custom_event(:info, message: message, **params)
    end
  end

  # Log an exception to the Rails log and to NewRelic. The `expected` flag is
  # used to separate expected exceptions, like search timeouts or auth failures,
  # from unexpected exceptions, like runtime errors, in the error logs.
  #
  # @param message [Exception] the exception to log
  # @param expected [Boolean] whether the exception was expected
  # @param params [Hash] optional key-value data to log with the exception
  def self.log(exception, expected: false, **params)
    if expected
      Rails.logger.info("#{exception.class}: #{exception.message}")
    else
      backtrace = Rails.backtrace_cleaner.clean(exception.backtrace).join("\n")
      Rails.logger.error("#{exception.class}: #{exception.message}\n#{backtrace}")
    end

    if defined?(::NewRelic)
      ::NewRelic::Agent.notice_error(exception, expected: expected, custom_params: params)
    end
  end

  # Log extra HTTP request data to NewRelic. Logs the user's IP, user agent,
  # request params, and session cookies.
  #
  # @param request the HTTP request
  # @param session the Rails session
  # @param user [User] the current user
  def self.add_session_attributes(request, session, user)
    add_attributes("param", request_params(request))
    add_attributes("session", session_params(session))
    add_attributes("cookie", cookie_params(request.cookies))
    add_attributes("user", user_params(request, user))
  end

  # Get logged HTTP headers from request.
  def self.header_params(request)
    headers = request.headers.to_h.select { |header, value| header.match?(/\AHTTP_/) }
    headers = headers.transform_keys { |header| header.delete_prefix("HTTP_").downcase }
    headers = headers.select { |header, value| header.in?(HEADERS) }
    headers
  end

  def self.request_params(request)
    request.parameters.with_indifferent_access.except(:controller, :action).reject do |key, value|
      # exclude strange URL params that don't come from our app.
      !key.match?(/\A[a-z._]+\z/) || key.match?(/\A_|_\z/)
    end
  end

  def self.session_params(session)
    session.to_h.with_indifferent_access.slice(:session_id, :started_at, :last_authenticated_at)
  end

  def self.cookie_params(cookies)
    # XXX see also ApplicationHelper#cookie_data_attributes
    cookies.slice(*%w[
      news-ticker hide_upgrade_account_notice hide_verify_account_notice
      hide_dmail_notice dab show-relationship-previews post_preview_size
      post_preview_show_votes
    ])
  end

  def self.user_params(request, user)
    {
      id: user&.id,
      name: user&.name,
      level: user&.level_string,
      #ip: request.remote_ip,
      #country: CurrentUser.country,
      #safe_mode: CurrentUser.safe_mode?,
      #bot: UserAgent.new(request.headers["HTTP_USER_AGENT"]).is_bot?,
    }
  end

  def self.add_attributes(prefix, hash)
    attributes = flatten_hash(hash).transform_keys { |key| "#{prefix}.#{key}" }
    attributes.delete_if { |key, value| key.end_with?(*Rails.application.config.filter_parameters.map(&:to_s)) }
    add_custom_attributes(attributes)
  end

  private_class_method

  # @see https://docs.newrelic.com/docs/using-new-relic/data/customize-data/collect-custom-attributes/#ruby-att
  def self.add_custom_attributes(attributes)
    return unless defined?(::NewRelic)
    ::NewRelic::Agent.add_custom_attributes(attributes)
  end

  # flatten_hash({ foo: { bar: { baz: 42 } } })
  # => { "foo.bar.baz" => 42 }
  def self.flatten_hash(hash)
    hash.each_with_object({}) do |(k, v), h|
      if v.is_a?(Hash)
        flatten_hash(v).map do |h_k, h_v|
          h["#{k}.#{h_k}"] = h_v
        end
      else
        h[k.to_s] = v
      end
    end
  end
end

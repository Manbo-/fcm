# fcm = FCM::V1.new(key, json, name)
# fcm.authenticate
# fcm.topic_subscription("debug", registration_id)
# fcm.send({
#   topic: "debug",
#   notification: {
#     title: "title",
#     body: "body"
#   }
# })

class FCM::V1 < FCM
  def initialize(api_key, json_key_path, project_name, client_options = {})
    @api_key = api_key
    @json_key_path = json_key_path
    @project_name = project_name
    @client_options = client_options
  end

  def authenticate
    @authorization = {
      'Authorization' => "Bearer #{jwt_token}",
    }
  end

  def send(message)
    return if @project_name.empty?

    post_body = { 'message': message }
    extra_headers = {
      'Authorization' => "Bearer #{jwt_token}"
    }
    for_uri(BASE_URI_V1, extra_headers) do |connection|
      response = connection.post(
        "#{@project_name}/messages:send", post_body.to_json
      )
      build_response(response)
    end
  end

  def topic_subscription(topic, registration_id)
    for_uri(INSTANCE_ID_API, @authorization) do |connection|
      connection.headers["access_token_auth"] = "true"
      response = connection.post("/iid/v1/#{registration_id}/rel/topics/#{topic}")
      build_response(response)
    end
  end

  def info(iid_token)
    for_uri(INSTANCE_ID_API, @authorization) do |connection|
      connection.headers["access_token_auth"] = "true"
      response = connection.get("/iid/info/#{iid_token}")
      build_response(response)
    end
  end

  def for_uri(uri, extra_headers = {})
    raise AuthorizationError unless @authorization

    super
  end

  class AuthorizationError < StandardError
  end
end

require "multi_json"
require "sinatra/base"
require "sinatra/namespace"

class HerokuAPIStub < Sinatra::Base
  register Sinatra::Namespace

  configure do
    set :raise_errors,    true
    set :show_exceptions, false
  end

  helpers do
    def auth
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
    end

    def auth_credentials
      auth.provided? && auth.basic? ? auth.credentials : nil
    end

    def authorized!
      halt(401, "Unauthorized") unless auth_credentials
    end
  end

  post "/signup" do
    MultiJson.encode({ email: "kerry@heroku.com" })
  end

  namespace "/auth" do
    post "/reset_password" do
      MultiJson.encode({
        message: <<-eos
Check your inbox for the next steps.
If you don't receive an email, and it's not in your spam folder, this could mean you signed up with a different address.
        eos
      })
    end

    get "/finish_reset_password/:hash" do |hash|
      MultiJson.encode({ email: "kerry@heroku.com" })
    end

    post "/finish_reset_password/:hash" do |hash|
      MultiJson.encode({ email: "kerry@heroku.com" })
    end
  end

  namespace "/oauth" do
    get "/authorizations" do
      status(200)
      MultiJson.encode([])
    end

    post "/authorizations" do
      authorized!
      status(200)
      MultiJson.encode({
        id:         "authorization123@heroku.com",
        scope:      "all",
        created_at: Time.now,
        updated_at: Time.now,
        access_tokens: [],
        client: {
          id:           123,
          name:         "dashboard",
          redirect_uri: "https://dashboard.heroku.com/oauth/callback/heroku",
        },
        grants: [
          {
            code:       "454118bc-902d-4a2c-9d5b-e2a2abb91f6e",
            expires_in: 300,
          }
        ],
        refresh_tokens: []
      })
    end

    get "/clients/:id" do |id|
      status(200)
      MultiJson.encode({
        id:           id,
        name:         "An OAuth Client",
        redirect_uri: "https://example.com/oauth/callback/heroku",
        trusted:      false,
      })
    end

    post "/tokens" do
      status(200)
      MultiJson.encode({
        session_nonce: "0a80ac35-b9d8-4fab-9261-883bea77ad3a",
        authorization: {
          id: "authorization123@heroku.com",
        },
        access_token: {
          token:      "e51e8a64-29f1-4bbf-997e-391d84aa12a9",
          expires_in: 7200,
        },
        refresh_token: {
          token:      "faa180e4-5844-42f2-ad66-0c574a1dbed2",
          expires_in: 2592000,
        },
      })
    end
  end
end

if __FILE__ == $0
  $stdout.sync = $stderr.sync = true
  HerokuAPIStub.run! port: ENV["PORT"]
end

module EmailTracker
  class Rack
    def initialize(app)
      @app = app
    end

    def call(env)
      req = ::Rack::Request.new(env)

      if req.path_info =~ /^\/email\/track\/(.+).png/
        details = Base64.urlsafe_decode64(Regexp.last_match[1])
        name = nil
        email = nil
        activity_id = nil

        details.split('&').each do |kv|
          (key, value) = kv.split('=')
          case(key)
          when('name')
            name = value
          when('email')
            email = value
          when('activity_id')
            activity_id = value
          end
        end

        if name && email
          SentEmailOpen.create!({
            :name => name,
            :email => email,
            :activity_id => activity_id,
            :ip_address => req.ip,
            :opened => DateTime.now
          })
        end

        [ 200, { 'Content-Type' => 'image/png' }, [ File.read(File.join(File.dirname(__FILE__), 'track.png')) ] ]
      else
        @app.call(env)
      end
    end
  end
end
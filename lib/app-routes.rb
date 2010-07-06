#!/usr/bin/ruby

# file: app-routes.rb

class AppRoutes

  def initialize(params={})
    super()
    @route = {}
    @params = params
  end

  def routes()
    yield
  end

  def run(request)

    result = nil

    @route.each do |key, block|
      match = request.match(key)

      if match then

        args = match.captures
        @params[:captures] = *args

        if @route[key][:s] then
          raw_params = @route[key][:s].gsub(':','').match(key).captures
          @params.merge!(Hash[raw_params.map(&:to_sym).zip(args)])
        end 

        result = @route[key][:block].call *args

        break
      end
    end
    
    result
  end

  def get(arg,&block)
    methodx = {String: :string_get, Regexp: :regex_get}
    send (methodx[arg.class.to_s.to_sym]), arg, &block 
  end

  def string_get(raw_s, &block)
    s = raw_s.gsub(/\:\w+/,'(\w+)')
    @route[Regexp.new s] = {s: raw_s, block: block}
  end

  def regex_get(r, &block)
    @route[r] = {block: block}
  end

end


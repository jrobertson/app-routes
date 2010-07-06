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
          splat, raw_params2 = raw_params.each_with_index.partition {|x,i| x == '/*'}
          @params[:splat] = splat.map {|x,i| v = args[i]; args.delete_at(i); v}
          @params.merge!(Hash[raw_params2.map{|x,i| x.to_sym}.zip(args)])
        end 

        begin
          result = @route[key][:block].call *args
        rescue
          "app-routes error: " + ($!).to_s
        end

        break
      end
    end
    
    result
  end

  def get(arg,&block)
    methodx = {String: :string_get, Regexp: :regex_get}
    send (methodx[arg.class.to_s.to_sym]), arg, &block 
  end

  private

  def string_get(raw_s, &block)
    s = "^%s$" % raw_s.gsub(/\:[\w-]+/,'([\w-]+)').gsub(/\/\*/,'(.*)')
    @route[Regexp.new s] = {s: raw_s, block: block}
  end

  def regex_get(r, &block)
    @route[r] = {block: block}
  end

end


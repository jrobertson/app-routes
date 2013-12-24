#!/usr/bin/env ruby

# file: app-routes.rb

module AppRoutes

  attr_accessor :routes
  
  def initialize(logfile='/tmp/app-routes.log')
    @routes = {}
    @params = {}
  end
  
  def run_route(request)

    result = nil

    routes = @routes

    return unless routes

    route = routes.detect {|key, block|  request.match(key) }
    
    if route then
      key, block = route      
      match = request.match(key)

      args = match.captures
      @params[:captures] = *args

      if routes[key][:s] then
        raw_params = routes[key][:s].gsub(':','').match(key).captures

        splat, raw_params2 = raw_params.each_with_index.partition {|x,i| x == '/*'}
        @params[:splat] = splat.map {|x,i| v = args[i]; args.delete_at(i); v}

        @params.merge!(Hash[raw_params2.map{|x,i| x.to_sym}.zip(args)])
      end 

      begin
        result = routes[key][:block].call *args
      rescue Exception => e  

        err_label = e.message + " :: \n" + e.backtrace.join("\n")      
        raise 'app-routes: ' + request.inspect + ' ' + err_label
      end      
      
    end
    result
  end

  def get(arg,&block)
    methodx = {String: :string_get, Regexp: :regex_get}
    send (methodx[arg.class.to_s.to_sym]), arg, &block 
  end

  def add_route(arg)
    get(arg) {yield(@params)}
  end
  
  private

  def string_get(raw_s, &block)
    s = "^%s$" % raw_s.gsub(/\:[\w-]+/,'([\w-]+)').gsub(/\/\*/,'(.*)')
    @routes[Regexp.new s] = {s: raw_s, block: block}
  end

  def regex_get(r, &block)
    @routes[r] = {block: block}
  end

end
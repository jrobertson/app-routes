#!/usr/bin/env ruby

# file: app-routes.rb


module AppRoutes

  attr_accessor :routes
  
  def initialize(logfile='/tmp/app-routes.log')
    @get_routes, @post_routes = {}, {}
    @params = {}
  end
  
  def run_route(request, request_method='GET')

    result = nil

    return unless @get_routes or @post_routes

    route, routes = case request_method
      when 'GET'
        [@get_routes.detect {|key, block|  request.match(key) }, @get_routes]
      when 'POST'
        [@post_routes.detect {|key, block|  request.match(key) }, @post_routes]
    end
    
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

  def post(arg,&block)
    methodx = {String: :string_post, Regexp: :regex_post}
    send (methodx[arg.class.to_s.to_sym]), arg, &block 
  end

  def add_route(arg, request_method='GET')
    name = request_method == 'GET' ? :get : :post
    method(name).call(arg) {yield(@params)}
  end
  
  private

  def string_get(raw_s, &block)
    s = "^%s$" % raw_s.gsub(/\:[\w-]+/,'([\w-]+)').gsub(/\/\*/,'(.*)')
    @get_routes[Regexp.new s] = {s: raw_s, block: block}
  end

  def regex_get(r, &block)
    @get_routes[r] = {block: block}
  end

  def string_post(raw_s, &block)
    s = "^%s$" % raw_s.gsub(/\:[\w-]+/,'([\w-]+)').gsub(/\/\*/,'(.*)')
    @post_routes[Regexp.new s] = {s: raw_s, block: block}
  end

  def regex_post(r, &block)
    @post_routes[r] = {block: block}
  end

end
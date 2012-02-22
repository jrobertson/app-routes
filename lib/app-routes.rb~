#!/usr/bin/env ruby

# file: app-routes.rb

module AppRoutes

  def initialize()
    @route = {}
    @params = {}
  end
  
  def run_route(request)

    result = nil

    route = @route.detect {|key, block| request.match(key) }
    
    if route then
      key, block = route
      match = request.match(key)

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
      rescue Exception => e  

        err_label = e.message + " :: \n" + e.backtrace.join("\n")      
        puts err_label      
        "app-routes error: " + ($!).to_s
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


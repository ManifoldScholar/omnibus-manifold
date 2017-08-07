defaults = {
    :listen => [],
    :owner => nil,
    :group => nil,
    :mode => nil,
    :notifies => nil,
    :dir => nil,
    :socket => nil,
    :pid => true
}

define :puma_config, defaults do

  config_dir = File.dirname(params[:name])

  directory config_dir do
    recursive true
    action :create
  end

  tvars = params.clone
  params[:listen].each do |port, options|
    oarray = Array.new
    options.each do |k, v|
      oarray << ":#{k} => #{v}"
    end
    tvars[:listen][port] = oarray.join(", ")
  end

  template params[:name] do
    source params[:config_template]
    mode "0644"
    owner params[:owner] if params[:owner]
    group params[:group] if params[:group]
    mode params[:mode]   if params[:mode]
    variables params
    notifies *params[:notifies] if params[:notifies]
  end

end
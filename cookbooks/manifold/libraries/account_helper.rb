class AccountHelper
  attr_reader :node

  def initialize(node)
    @node = node
  end

  def manifold_user
    node['manifold']['user']['username']
  end

  def manifold_group
    node['manifold']['user']['group']
  end

  def web_server_user
    node['manifold']['web-server']['username']
  end

  def web_server_group
    node['manifold']['web-server']['group']
  end

  def redis_user
    node['manifold']['redis']['username']
  end

  def redis_group
    node['manifold']['redis']['username']
  end

  def postgresql_user
    node['manifold']['postgresql']['username']
  end

  def postgresql_group
    node['manifold']['postgresql']['username']
  end

  def elasticsearch_user
    node['manifold']['elasticsearch']['username']
  end

  def elasticsearch_group
    node['manifold']['elasticsearch']['username']
  end


  def users
    %W(
        #{manifold_user}
        #{web_server_user}
        #{redis_user}
        #{postgresgl_user}
      )
  end

  def groups
    %W(
        #{manifold_group}
        #{web_server_group}
        #{redis_group}
        #{postgresgl_group}
      )
  end
end

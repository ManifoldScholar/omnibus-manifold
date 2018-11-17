module Manifold
  class Jenkins
    include Manifold::UsesEnvironment

    BUILD_JOB_TASK_NAME = 'omnibus-manifold'

    def build!(version, dry_run: false)
      raise TypeError, "must be a version: #{version.inspect}" unless version.kind_of? Manifold::Version

      params = {
        cause: "Triggered by manifold release",
        omnibusBuild: dry_run ? 'No' : 'Yes',
        tag: version.to_s,
        token: build_token,
      }.stringify_keys

      client.job.build BUILD_JOB_TASK_NAME, params
    end

    attr_lazy_reader :client do
      JenkinsApi::Client.new server_url: server_url
    end

    attr_lazy_reader :server_url do
      env_fetch 'JENKINS_API_URL'
    end

    attr_lazy_reader :build_token do
      env_fetch 'JENKINS_API_BUILD_TOKEN'
    end
  end
end

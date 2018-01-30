# This monkey patch works around a bug in Omnibus that causes git versioning as
# well as license file creation to fail (returning the wrong version for the
# former and finding no licenses for the latter) in case sources aren't cleaned
# when building (which can easily happen if we're building from cache and the
# sources haven't needed cleaning because they weren't built).
#
# This fixes the issue by always cleaning software sources, regardless of
# whether they'll be built or restored from cache (which also means we clean
# them twice when actually building... but that's the lesser of two evils).
#
# This also handles another edge case with git sources, where simply cleaning
# isn't enough, because Omnibus's Software fetcher is perfectly happy with
# using the git SHA that corresponds to the version we are trying to build (it
# uses `git ls-remote` for that) without actually fetching that tag, whereas
# Omnibus's build version engine actually wants the tag locally to run `git
# describe`. As a result, merely running fetcher#clean won't download the tag,
# and the resulting package version won't be the right tag (it'll be the last
# tag we pulled plus a number of commit, i.e. a pre-release).

module CleanSoftwareExtension
  def build_me(*args)
    fetcher.send(:git, 'fetch') if fetcher.is_a? Omnibus::GitFetcher
    fetcher.clean
    super(*args)
  end
end

::Omnibus::Software.class_eval do
  prepend CleanSoftwareExtension
end
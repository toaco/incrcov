require 'git'

module Incrcov
  class GitHelper
    def initialize(repo_path = '.')
      @repo_path = repo_path
      @repo = Git.open(@repo_path)
    end

    def diff(commit1, commit2)
      @repo.diff(commit1, commit2)
    end
  end
end

class GitHooksExt < Formula
  desc "Semantic Git hooks for reference changes"
  homepage "https://github.com/ciembor/git-hooks-ext"
  url "https://github.com/ciembor/git-hooks-ext/releases/download/v0.4.0/git-hooks-ext-0.4.0.tar.gz"
  version "0.4.0"
  sha256 "3f69c47dab86345af0a42d87f6923c4d5cc08a407e99db1c0571a3d3ed7c3d3e"
  license "GPL-2.0-only"

  uses_from_macos "git"

  def install
    system "make", "install", "PREFIX=#{prefix}"
    doc.install "README.md", "COPYRIGHT"
  end

  test do
    ENV["GIT_CONFIG_GLOBAL"] = File::NULL
    ENV["GIT_CONFIG_NOSYSTEM"] = "1"
    assert_equal "git-hooks-ext #{version}\n", shell_output("#{bin}/git-hooks-ext --version")
    system "git", "init", "-q", testpath/"repo"
    cd testpath/"repo" do
      system "git", "-c", "user.name=Package Test", "-c", "user.email=test@example.com",
             "commit", "--allow-empty", "-qm", "initial"
      system bin/"git-hooks-ext", "install", "--legacy"
      hook = Pathname(".git/hooks/branch-created")
      hook.write "#!/bin/sh\nprintf '%s\\n' \"$1\" > branch.out\n"
      hook.chmod 0755
      system "git", "branch", "packaged"
      assert_equal "packaged\n", File.read("branch.out")
    end
  end
end

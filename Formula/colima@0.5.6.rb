class ColimaAT056 < Formula
  desc "Container runtimes on MacOS (and Linux) with minimal setup"
  homepage "https://github.com/abiosoft/colima/blob/main/README.md"
  url "https://github.com/abiosoft/colima.git",
      tag:      "v0.5.6",
      revision: "ceef812c32ab74a49df9f270e048e5dced85f932"
  license "MIT"
  head "https://github.com/abiosoft/colima.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "go" => :build
  depends_on "lima"

  def install
    project = "github.com/abiosoft/colima"
    ldflags = %W[
    -s -w
    -X #{project}/config.appVersion=#{version}
    -X #{project}/config.revision=#{Utils.git_head}
  ]
  system "go", "build", *std_go_args(ldflags: ldflags), "./cmd/colima"

  generate_completions_from_executable(bin/"colima", "completion")
end

service do
  run [opt_bin/"colima", "start", "-f"]
  keep_alive successful_exit: true
  environment_variables PATH: std_service_path_env
  error_log_path var/"log/colima.log"
  log_path var/"log/colima.log"
  working_dir Dir.home
end

test do
  assert_match version.to_s, shell_output("#{bin}/colima version 2>&1")
  assert_match "colima is not running", shell_output("#{bin}/colima status 2>&1", 1)
end
end
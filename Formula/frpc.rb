class Frpc < Formula
  desc "Fast reverse proxy to expose a local server behind a NAT or firewall"
  homepage "https://github.com/fatedier/frp"
  url "https://github.com/fatedier/frp.git",
      :tag      => "v0.24.1",
      :revision => "cbf9c731a096ce33ec282ed913a25cb2e5f05303"

  depends_on "go" => :build

  def install
    ENV["XC_OS"] = "darwin"
    ENV["XC_ARCH"] = "amd64"
    ENV["GOPATH"] = buildpath
    contents = Dir["{*,.git,.gitignore}"]
    (buildpath/"src/github.com/fatedier/frp").install contents

    (buildpath/"bin").mkpath
    (etc/"frp").mkpath

    cd "src/github.com/fatedier/frp" do
      system "make", "frpc"
      bin.install "bin/frpc"
      etc.install "conf/frpc.ini" => "frp/frpc.ini"
      etc.install "conf/frpc_full.ini" => "frp/frpc_full.ini"
      prefix.install_metafiles
    end
  end

  plist_options :manual => "frpc -c #{HOMEBREW_PREFIX}/etc/frp/frpc.ini"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>KeepAlive</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/frpc</string>
          <string>-c</string>
          <string>#{etc}/frp/frpc.ini</string>
        </array>
        <key>StandardErrorPath</key>
        <string>#{var}/log/frpc.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/frpc.log</string>
      </dict>
    </plist>
  EOS
  end

  test do
    system bin/"frpc", "-v"
  end
end

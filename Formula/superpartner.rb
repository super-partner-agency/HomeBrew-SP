# Fórmula de Homebrew de SuperPartner (el agente). Generada por scripts/formula-brew.mjs.
# El tap público es adiazpe/HomeBrew-SP (brew sólo mira Formula/):
#   brew tap adiazpe/sp
#   brew install adiazpe/sp/superpartner
#   brew services start superpartner
class Superpartner < Formula
  desc "SuperPartner: tus máquinas a distancia, igual que en local"
  homepage "https://auth.superpartner.ca"
  version "0.0.2"
  license "NONE"

  on_macos do
    on_arm do
      url "https://auth.superpartner.ca/descargas/v0.0.2/superpartner-darwin-arm64"
      sha256 "c0a5328cfca07ddf3ddac971b530b8b9ac047862b0b981dc1594cab69a69a58f"
    end
    on_intel do
      url "https://auth.superpartner.ca/descargas/v0.0.2/superpartner-darwin-x64"
      sha256 "05fbc321e8a34347bb8e0b41e364c90bcb1b753198fa6ba57f8b07ed506bc9a2"
    end
  end

  # El icono, servido por el hub como los binarios.
  resource "icono" do
    url "https://auth.superpartner.ca/descargas/v0.0.2/superpartner.icns"
    sha256 "25bfa2a35cc7c1af2a3a9c2c67fd0ba56a2ff0095c35be955f44cabb2e56e468"
  end

  def install
    # Un paquete .app mínimo, sin ventana ni Dock (LSUIElement): existe para que
    # macOS muestre «Super Partner» con su icono en Ajustes → Ítems de inicio,
    # en vez del nombre del archivo con el icono genérico de ejecutable.
    app = prefix/"Super Partner.app/Contents"
    (app/"MacOS").mkpath
    (app/"Resources").mkpath
    binario = Dir["superpartner-darwin-*"].first
    (app/"MacOS").install binario => "superpartner"
    resource("icono").stage { (app/"Resources").install "superpartner.icns" }
    (app/"Info.plist").write <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0"><dict>
        <key>CFBundleIdentifier</key><string>ca.superpartner.agente</string>
        <key>CFBundleName</key><string>Super Partner</string>
        <key>CFBundleDisplayName</key><string>Super Partner</string>
        <key>CFBundleExecutable</key><string>superpartner</string>
        <key>CFBundleIconFile</key><string>superpartner</string>
        <key>CFBundlePackageType</key><string>APPL</string>
        <key>CFBundleShortVersionString</key><string>0.0.2</string>
        <key>CFBundleVersion</key><string>0.0.2</string>
        <key>LSUIElement</key><true/>
        <key>LSMinimumSystemVersion</key><string>12.0</string>
      </dict></plist>
    PLIST
    # Firma ad-hoc: la que Apple Silicon exige para ejecutar. No es la de pago.
    system "codesign", "--force", "--deep", "--sign", "-", prefix/"Super Partner.app"
    bin.install_symlink app/"MacOS/superpartner"
  end

  service do
    run [prefix/"Super Partner.app/Contents/MacOS/superpartner"]
    environment_variables REMOTO_HUB: "https://auth.superpartner.ca"
    keep_alive true
    log_path var/"log/superpartner.log"
    error_log_path var/"log/superpartner.log"
  end

  test do
    assert_match "superpartner", shell_output("#{bin}/superpartner --version 2>&1", 0)
  end
end

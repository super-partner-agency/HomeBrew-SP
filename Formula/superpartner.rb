# Fórmula de Homebrew de SuperPartner (el agente). Generada por scripts/formula-brew.mjs.
# El tap público es adiazpe/HomeBrew-SP (brew sólo mira Formula/):
#   brew tap adiazpe/sp
#   brew install adiazpe/sp/superpartner
#   superpartner --instalar-servicio --hub https://…
class Superpartner < Formula
  desc "SuperPartner: tus máquinas a distancia, igual que en local"
  homepage "https://auth.superpartner.ca"
  version "0.0.6"
  license "NONE"

  on_macos do
    on_arm do
      url "https://auth.superpartner.ca/descargas/v0.0.6/superpartner-darwin-arm64"
      sha256 "6ddf45fcb0d15c0ae65d96e91f710dc2122ce09078f6c0971bae54c87b04cffe"
    end
    on_intel do
      url "https://auth.superpartner.ca/descargas/v0.0.6/superpartner-darwin-x64"
      sha256 "b77d1aa8ae3affccee79354da7c4258b6291daf97890ee923e93376e8761206f"
    end
  end

  # El icono, servido por el hub como los binarios.
  resource "icono" do
    url "https://auth.superpartner.ca/descargas/v0.0.6/superpartner.icns"
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
    # Lo descargado llega sin permiso de ejecución; brew sólo lo arregla en bin/.
    chmod 0755, app/"MacOS/superpartner"
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
        <key>CFBundleShortVersionString</key><string>0.0.6</string>
        <key>CFBundleVersion</key><string>0.0.6</string>
        <key>LSUIElement</key><true/>
        <key>LSMinimumSystemVersion</key><string>12.0</string>
      </dict></plist>
    PLIST
    # Firma ad-hoc: la que Apple Silicon exige para ejecutar. No es la de pago.
    system "codesign", "--force", "--deep", "--sign", "-", prefix/"Super Partner.app"
    bin.install_symlink app/"MacOS/superpartner"
  end

  # Sin bloque service: el agente instala su propio plist de launchd con
  # AssociatedBundleIdentifiers, que es lo que hace que macOS muestre
  # «Super Partner» con su icono en Ítems de inicio. brew no escribe esa clave.
  def post_install
    system "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
           "-f", prefix/"Super Partner.app"
  end

  def caveats
    <<~EOS
      Para que arranque con tu sesión y aparezca como «Super Partner» en Ítems de inicio:
        superpartner --instalar-servicio --hub https://auth.superpartner.ca
      Quitar:  superpartner --quitar-servicio
      Registro: ~/Library/Logs/SuperPartner/superpartner.log
    EOS
  end

  test do
    assert_match "superpartner", shell_output("#{bin}/superpartner --version 2>&1", 0)
  end
end

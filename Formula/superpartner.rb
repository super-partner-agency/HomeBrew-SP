# Fórmula de Homebrew de SuperPartner (el agente). Generada por scripts/formula-brew.mjs.
# El tap público es adiazpe/HomeBrew-SP (brew sólo mira Formula/):
#   brew tap adiazpe/sp
#   brew install adiazpe/sp/superpartner
#   brew services start superpartner
class Superpartner < Formula
  desc "SuperPartner: tus máquinas a distancia, igual que en local"
  homepage "https://auth.superpartner.ca"
  version "0.0.1"
  license "NONE"

  on_macos do
    on_arm do
      url "https://auth.superpartner.ca/descargas/v0.0.1/superpartner-darwin-arm64"
      sha256 "bf3ee1c0b7d3111e43e0015f18167426707d493d827fe1062dcba1b6dd7b0155"
    end
    on_intel do
      url "https://auth.superpartner.ca/descargas/v0.0.1/superpartner-darwin-x64"
      sha256 "9813db2912167a64b211b97726f73f45f5fcd046ecf93d1f8298b578ef1a8d51"
    end
  end

  def install
    binario = Dir["superpartner-darwin-*"].first
    bin.install binario => "superpartner"
    # Firma ad-hoc: la que Apple Silicon exige para ejecutar. No es la de pago.
    system "codesign", "--force", "--sign", "-", bin/"superpartner"
  end

  service do
    run [opt_bin/"superpartner"]
    environment_variables REMOTO_HUB: "https://auth.superpartner.ca"
    keep_alive true
    log_path var/"log/superpartner.log"
    error_log_path var/"log/superpartner.log"
  end

  test do
    assert_match "superpartner", shell_output("#{bin}/superpartner --version 2>&1", 0)
  end
end

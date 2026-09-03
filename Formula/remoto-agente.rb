# Fórmula de Homebrew para el agente de remoto. Generada por scripts/formula-brew.mjs.
# El repo SuperPartner es el tap (brew sólo mira Formula/):
#   brew tap adiazpe/superpartner git@github.com:adiazpe/SuperPartner.git
#   brew install adiazpe/superpartner/remoto-agente
#   brew services start remoto-agente
class RemotoAgente < Formula
  desc "Agente de remoto: tus máquinas a distancia, igual que en local"
  homepage "https://auth.superpartner.ca"
  version "0.0.1"
  license "NONE"

  on_macos do
    on_arm do
      url "https://auth.superpartner.ca/descargas/v0.0.1/remoto-agente-darwin-arm64"
      sha256 "7cf8cb324f72cd53835e3798bd47a287b8bd6dd77623138cdb11db44d102f067"
    end
    on_intel do
      url "https://auth.superpartner.ca/descargas/v0.0.1/remoto-agente-darwin-x64"
      sha256 "88578a2e899f3c913d2fa7a295bdbbf5f9ac08277e3e1f1b64e1d687f2ae06e2"
    end
  end

  def install
    binario = Dir["remoto-agente-darwin-*"].first
    bin.install binario => "remoto-agente"
    # Firma ad-hoc: la que Apple Silicon exige para ejecutar. No es la de pago.
    system "codesign", "--force", "--sign", "-", bin/"remoto-agente"
  end

  service do
    run [opt_bin/"remoto-agente"]
    environment_variables REMOTO_HUB: "https://auth.superpartner.ca"
    keep_alive true
    log_path var/"log/remoto-agente.log"
    error_log_path var/"log/remoto-agente.log"
  end

  test do
    assert_match "remoto-agente", shell_output("#{bin}/remoto-agente --version 2>&1", 0)
  end
end

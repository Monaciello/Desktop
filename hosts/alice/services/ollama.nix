# Ollama — local LLM inference for Continue (VSCodium) and CLI
# CPU-only: Vega 8 integrated GPU not supported by ROCm
{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    acceleration = false;
    loadModels = [
      "qwen2.5-coder:7b"   # Chat, inline edits
      "qwen2.5-coder:1.5b" # Autocomplete
    ];
  };

  environment.systemPackages = [ pkgs.ollama ];
}

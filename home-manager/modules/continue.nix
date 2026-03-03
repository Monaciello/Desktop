# Continue — AI coding assistant config for VSCodium
# Points at local Ollama (services.ollama on alice)
{ ... }:
{
  home.file.".continue/config.yaml" = {
    text = ''
      name: Ollama Local
      version: 0.0.1
      schema: v1

      models:
        - name: Qwen 2.5 Coder 7B
          provider: ollama
          model: qwen2.5-coder:7b
          apiBase: http://localhost:11434
        - name: Qwen 2.5 Coder 1.5B
          provider: ollama
          model: qwen2.5-coder:1.5b
          apiBase: http://localhost:11434
    '';
  };
}

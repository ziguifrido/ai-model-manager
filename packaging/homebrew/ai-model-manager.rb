cask "ai-model-manager" do
  version "0.1.4"
  sha256 "{{SHA256}}"

  url "https://github.com/ziguifrido/ai-model-manager/releases/download/v#{version}/AIModelManager.zip"

  name "AI Model Manager"
  desc "Discover and manage local AI models from Ollama, LM Studio, Hugging Face, MLX, and vLLM"
  homepage "https://github.com/ziguifrido/my-ai-models"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "AIModelManager.app"

  zap trash: [
    "~/Library/Application Support/AI Model Manager",
    "~/Library/Caches/com.marcos.my-ai-models",
    "~/Library/Preferences/com.marcos.my-ai-models.plist",
  ]
end

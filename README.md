# Alton.nvim

An AI-powered Neovim plugin that provides intelligent code explanations using various LLM providers.

## Features

- **Code Explanations**: Get AI-powered explanations for your code
- **Multiple LLM Providers**: Support for Groq, OpenAI, Ollama, and Anthropic
- **Keyboard Shortcuts**: Quick access to explain functionality
- **Customizable**: Configure models, providers, and behavior

## Requirements

- Neovim >= 0.7.0
- curl (for API requests)
- An LLM provider account or local Ollama setup

## Installation

### Using [Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "syedowais312/alton.nvim",
  config = function()
    require("alton").setup({
      -- Configuration options here
    })
  end,
}
```

## Configuration

### Groq (Default)

```lua
{
  "syedowais312/alton.nvim",
  config = function()
    require("alton").setup({
      provider = "groq",
      groq = {
        api_key = "your_groq_api_key_here",
        model = "llama-3.1-8b-instant",
      },
    })
  end,
}
```

### Ollama (Local)

```lua
{
  "syedowais312/alton.nvim",
  config = function()
    require("alton").setup({
      provider = "ollama",
      ollama = {
        model = "qwen2.5-coder:1.5b", -- Your preferred model
        url = "http://localhost:11434/api/generate", -- Default Ollama URL
      },
    })
  end,
}
```

### OpenAI

```lua
{
  "syedowais312/alton.nvim",
  config = function()
    require("alton").setup({
      provider = "openai",
      openai = {
        api_key = "your_openai_api_key_here",
        model = "gpt-3.5-turbo",
      },
    })
  end,
}
```

## Setup Instructions

### For Groq

1. Sign up at [Groq](https://groq.com/)
2. Get your API key from the dashboard
3. Set the `api_key` in your configuration

### For Ollama

1. Install Ollama: `curl -fsSL https://ollama.ai/install.sh | sh`
2. Pull a model: `ollama pull qwen2.5-coder:1.5b`
3. Start Ollama service: `ollama serve`
4. Configure the plugin with your model name

### For OpenAI

1. Sign up at [OpenAI](https://platform.openai.com/)
2. Get your API key from the dashboard
3. Set the `api_key` in your configuration

## Usage

Once configured, use the following keyboard shortcuts:

- `F2`: Explain the current line/selection
- `F3`: Custom explanation prompt

The plugin will:
1. Analyze the current line or selected code
2. Send it to your configured LLM provider
3. Display the explanation in a floating window

## Configuration Options

### General Options

```lua
require("alton").setup({
  provider = "groq", -- "groq", "openai", "ollama", "anthropic"
  
  -- Provider-specific configurations
  groq = {
    api_key = "your_api_key",
    model = "llama-3.1-8b-instant",
  },
  
  ollama = {
    model = "codellama",
    url = "http://localhost:11434/api/generate",
  },
  
  openai = {
    api_key = "your_api_key",
    model = "gpt-3.5-turbo",
  },
})
```

### Provider-Specific Notes

- **Groq**: Requires API key, offers fast inference
- **Ollama**: Local models, no API key needed
- **OpenAI**: Requires API key, high-quality responses
- **Anthropic**: Requires API key, good for code analysis

## Troubleshooting

### "LLM provider not initialized"

- Ensure your configuration is correct
- Check that your API key is valid
- Verify network connectivity for cloud providers
- For Ollama, ensure the service is running

### "Empty response from [provider]"

- Check your API key and model name
- Verify the model is available (for Ollama: `ollama list`)
- Check internet connection for cloud providers
- Try a different model

### Debug Mode

Add debug messages to see what's happening:

```lua
{
  "syedowais312/alton.nvim",
  config = function()
    vim.notify("Setting up alton", vim.log.levels.INFO)
    require("alton").setup({
      -- your config here
    })
  end,
}
```

Check messages with `:messages` in Neovim.

## Development

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Local Development

```bash
# Clone your repository
git clone https://github.com/syedowais312/alton.nvim.git
cd alton.nvim

# Link it in your Neovim config
{
  dir = "/path/to/alton.nvim",
  config = function()
    require("alton").setup({
      -- your config
    })
  end,
}
```

## License

MIT License

## Credits

Created by [Syed Owais](https://github.com/syedowais312)

## Support

If you encounter issues:
1. Check the troubleshooting section
2. Verify your configuration
3. Open an issue on GitHub with details about your setup
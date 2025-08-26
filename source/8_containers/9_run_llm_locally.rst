#############################
8.9 Run LLM Locally in Docker
#############################

=====================
Why Run LLMs Locally?
=====================

Running Large Language Models (LLMs) locally offers several advantages for developers and organizations:

**Privacy & Security**

- Your data never leaves your infrastructure
- No risk of sensitive information being sent to third-party APIs
- Complete control over data handling and storage

**Cost Efficiency**

- No per-token charges or API fees
- Predictable resource costs
- Better for high-volume applications

**Performance & Reliability**

- No network latency or internet dependency
- Guaranteed availability
- Consistent response times

**Development & Testing**

- Experiment with different models freely
- Debug without external API limitations
- Create reproducible testing environments

**Compliance**

- Meet strict data governance requirements
- Maintain regulatory compliance (GDPR, HIPAA, etc.)
- Keep intellectual property secure

================
Method 1: Ollama
================

**What is Ollama?**

Ollama is a lightweight, extensible framework for running large language models locally. It provides:

- Simple command-line interface for model management
- Optimized inference engine with quantization support
- RESTful API for integration with applications
- Support for popular models (Llama, Mistral, CodeLlama, etc.)
- Automatic GPU acceleration when available

**Setting Up Ollama**

.. code-block:: bash

    # Run Ollama container with GPU support (if available)
    docker run -d --name ollama \
        --gpus all \
        -v ollama:/root/.ollama \
        -p 11434:11434 \
        ollama/ollama:latest

    # For systems without GPU, omit the --gpus flag
    # docker run -d --name ollama -v ollama:/root/.ollama -p 11434:11434 ollama/ollama:latest

    # Wait for the API to be ready
    curl -sf http://localhost:11434/api/version
    
    # Access the container to manage models
    docker exec -it ollama bash 
    
    # Pull and run a lightweight model (good for testing)
    ollama pull qwen2:1.5b
    ollama run qwen2:1.5b

**Finding and Choosing Models**

Ollama supports many popular models. You can:

1. **Browse available models**: Visit https://ollama.com/library
2. **Popular models by size**:
   
   - **Small (1-3B parameters)**: Good for basic tasks, fast inference
     
     - ``qwen2:1.5b`` - General purpose, multilingual
     - ``phi3:mini`` - Microsoft's efficient model
     - ``gemma2:2b`` - Google's lightweight model
   
   - **Medium (7-8B parameters)**: Balanced performance and speed
     
     - ``llama3:8b`` - Meta's general purpose model
     - ``mistral:7b`` - Excellent for code and reasoning
     - ``codellama:7b`` - Specialized for code generation
   
   - **Large (13B+ parameters)**: Best quality, requires more resources
     
     - ``llama3:70b`` - High-quality responses (requires significant RAM)
     - ``mixtral:8x7b`` - Mixture of experts architecture

3. **Check model requirements**:

.. code-block:: bash

    # List installed models
    ollama list
    
    # Get model information
    ollama show qwen2:1.5b

**Managing Models**

.. code-block:: bash

    # Pull a specific model
    ollama pull llama3:8b
    
    # Remove a model to save space
    ollama rm qwen2:1.5b
    
    # Update a model
    ollama pull llama3:8b  # Re-pulling updates the model

=========================
Testing Ollama Deployment
=========================

**Interactive Testing**

.. code-block:: bash

    # Start an interactive session
    ollama run qwen2:1.5b
    # Type your questions and press Enter
    # Use /bye to exit

**Command Line Testing**

.. code-block:: bash

    # Single prompt execution
    ollama run qwen2:1.5b "Write a 2-line poem about containers."

**API Testing**

.. code-block:: bash

    # Simple API call
    curl http://localhost:11434/api/generate -d '{
        "model": "qwen2:1.5b",
        "prompt": "Explain what a tensor is in one sentence.",
        "stream": false
    }'

.. code-block:: bash

    # Streaming response (real-time output)
    curl -N http://localhost:11434/api/generate -d '{
        "model": "qwen2:1.5b",
        "prompt": "Explain DevOps in simple terms.",
        "stream": true
    }'

**Integration Example (Python)**

.. code-block:: python

    import requests
    import json

    def ask_ollama(prompt, model="qwen2:1.5b"):
        response = requests.post("http://localhost:11434/api/generate", 
                               json={
                                   "model": model,
                                   "prompt": prompt,
                                   "stream": False
                               })
        return response.json()["response"]

    # Usage
    answer = ask_ollama("What is Docker?")
    print(answer)

======================================================
Method 2: Hugging Face Text Generation Inference (TGI)
======================================================

**What is TGI?**

Text Generation Inference (TGI) is Hugging Face's production-ready inference server for large language models. It offers:

- **Optimized Performance**: Highly optimized inference engine with batching and caching
- **Production Ready**: Built for high-throughput, low-latency serving
- **Quantization Support**: Built-in support for 4-bit and 8-bit quantization
- **Streaming**: Real-time token streaming for better user experience
- **Enterprise Features**: Metrics, health checks, and monitoring endpoints

**One-liner Deployment with TGI**

.. code-block:: bash

    # Set model and cache directory
    MODEL=Qwen/Qwen2-1.5B-Instruct
    VOL=$HOME/hf-cache
    
    docker run -d --name tgi --gpus all --shm-size 1g \
      -p 8080:80 -v "$VOL":/data \
      ghcr.io/huggingface/text-generation-inference:latest \
      --model-id $MODEL \
      --quantize eetq \
      --max-input-tokens 2048 --max-total-tokens 4096

**For Different Hardware Configurations**

.. code-block:: bash

    # For 4GB GPU (GTX 1050 Ti, RTX 3050)
    # Uses 4-bit quantization for extreme VRAM savings
    MODEL=Qwen/Qwen2-1.5B-Instruct
    docker run -d --name tgi --gpus all --shm-size 1g \
      -p 8080:80 -v "$HOME/hf-cache":/data \
      ghcr.io/huggingface/text-generation-inference:latest \
      --model-id $MODEL \
      --quantize bitsandbytes-nf4 \
      --max-input-tokens 1024 --max-total-tokens 2048

.. code-block:: bash

    # For CPU-only deployment (no GPU)
    MODEL=Qwen/Qwen2-1.5B-Instruct
    docker run -d --name tgi --shm-size 1g \
      -p 8080:80 -v "$HOME/hf-cache":/data \
      ghcr.io/huggingface/text-generation-inference:latest \
      --model-id $MODEL \
      --max-input-tokens 1024 --max-total-tokens 2048

**Using Private/Gated Models**

.. code-block:: bash

    # For models requiring authentication (get token from https://huggingface.co/settings/tokens)
    export HF_TOKEN=your_token_here
    
    MODEL=meta-llama/Llama-2-7b-chat-hf  # Example gated model
    docker run -d --name tgi --gpus all --shm-size 1g \
      -p 8080:80 -v "$HOME/hf-cache":/data \
      -e HF_TOKEN=$HF_TOKEN \
      ghcr.io/huggingface/text-generation-inference:latest \
      --model-id $MODEL \
      --quantize eetq

**Testing TGI Deployment**

.. code-block:: bash

    # Wait for the model to load (check logs)
    docker logs -f tgi
    
    # Health check
    curl http://localhost:8080/health

    # Get model info
    curl http://localhost:8080/info

**API Usage Examples**

.. code-block:: bash

    # Simple completion (non-streaming)
    curl -s http://localhost:8080/generate \
      -H 'Content-Type: application/json' \
      -d '{
        "inputs": "What is DevOps?",
        "parameters": {
          "max_new_tokens": 128,
          "temperature": 0.7
        },
        "stream": false
      }'

.. code-block:: bash

    # Streaming response (real-time tokens)
    curl -N http://localhost:8080/generate_stream \
      -H 'Content-Type: application/json' \
      -d '{
        "inputs": "Explain containers in simple terms:",
        "parameters": {
          "max_new_tokens": 200,
          "temperature": 0.8,
          "top_p": 0.9
        }
      }'

.. code-block:: bash

    # Chat completion format
    curl -s http://localhost:8080/generate \
      -H 'Content-Type: application/json' \
      -d '{
        "inputs": "<|im_start|>system\nYou are a helpful DevOps assistant.<|im_end|>\n<|im_start|>user\nWhat is Docker?<|im_end|>\n<|im_start|>assistant\n",
        "parameters": {
          "max_new_tokens": 150,
          "temperature": 0.7,
          "stop": ["<|im_end|>"]
        },
        "stream": false
      }'

**Method Comparison**

+------------------+-------------------+------------------+------------------+
| Aspect           | Ollama            | TGI              | Recommendation   |
+==================+===================+==================+==================+
| **Ease of Use**  | Excellent         | Good             | Ollama for       |
|                  | (CLI interface)   | (One command)    | beginners        |
+------------------+-------------------+------------------+------------------+
| **Performance**  | Very Good         | Excellent        | TGI for          |
|                  | (Optimized)       | (Production)     | production       |
+------------------+-------------------+------------------+------------------+
| **Model Variety**| Good              | Extensive        | TGI for          |
|                  | (Curated)         | (Any HF model)   | variety          |
+------------------+-------------------+------------------+------------------+
| **Quantization** | Built-in          | Advanced         | TGI for          |
|                  | (GGML/GGUF)       | (Multiple types) | optimization     |
+------------------+-------------------+------------------+------------------+
| **Production**   | Good              | Excellent        | TGI for          |
| **Features**     | (Basic API)       | (Full featured)  | enterprise       |
+------------------+-------------------+------------------+------------------+
| **Resource**     | Lower             | Medium           | Ollama for       |
| **Usage**        | (Efficient)       | (Optimized)      | limited hardware |
+------------------+-------------------+------------------+------------------+
| **Streaming**    | Yes               | Yes              | Both support     |
|                  | (Built-in)        | (Built-in)       | real-time apps   |
+------------------+-------------------+------------------+------------------+

**When to Use Each Method:**

- **Ollama**: Perfect for learning, experimentation, simple applications, and resource-constrained environments
- **TGI**: Best for production deployments, high performance requirements, enterprise use, and access to the full Hugging Face model ecosystem

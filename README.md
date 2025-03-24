# FairlyAccess Accessibility Audit API

Dieser Code stellt die API für die VS Code Extension von Fairly Access bereit und wurde im Rahmen meiner BA entwickelt.

# Installation

1. Install Elixir & Erlang (Windows. For other Systems: https://elixir-lang.org/install.html)
  ```bash
    sudo add-apt-repository ppa:rabbitmq/rabbitmq-erlang
    sudo apt update
    sudo apt install git elixir erlang
  ```
2. Clone Repo
  ```bash
    git clone https://github.com/justinpennerthkoeln/elixir_accessibility_audit.git
    cd elixir_accessibility_audit
  ```
3. Add Variables to .zshrc / .bashrc
  ```bash
    nano ~/.bashrc
    --------------
  export DB_USERNAME=username
  export DB_PASSWORD=password
  export DB_HOSTNAME=localhost
  export DB_NAME=e***a_api
  export DB_PORT=3**2
  export DB_POOL_SIZE=10
  export SECRET_KEY_BASE=mbrie*****BpNnvvgEnF4g7RBP9b8bwlzp1eev5Is/Pnnp4+DXrUhj1a0
  export BASE_PATH=/
  export OPEN_AI_API_KEY=sk-proj-***RsA
  ```
4. Install Deps
  ```bash
    mix deps.get
  ```
6. Create Ecto Database (Current solution. May change in future)
  ```bash
    mix ecto.create
    mix ecto.migrate
  ```
7. Start elixir phoenix
  ```bash
    mix phx.server
  ```
#!/bin/bash

# ==============================================================================
# All-in-One Development Environment Setup Script for Ubuntu
#
# This script installs and configures:
# - Zsh + Oh My Zsh (as the default shell)
#   - zsh-syntax-highlighting plugin
#   - zsh-autosuggestions plugin
# - Git
# - Nginx (web server)
# - Certbot (for SSL/TLS certificates with Nginx)
# - Docker Engine
# - Docker Compose
#
# It is designed to be idempotent, meaning it can be run multiple times
# without causing issues.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper Functions for Logging ---
log_info() {
    echo -e "\n\e[1;34m[INFO]\e[0m $1"
}

log_success() {
    echo -e "\e[1;32m[SUCCESS]\e[0m $1"
}

log_warning() {
    echo -e "\e[1;33m[WARNING]\e[0m $1"
}


# --- 1. System Update and Prerequisites ---
log_info "Updating package lists and upgrading existing packages..."
sudo apt-get update
sudo apt-get upgrade -y
log_success "System updated."

log_info "Installing prerequisite packages: curl, wget, gnupg, software-properties-common..."
sudo apt-get install -y curl wget gnupg software-properties-common
log_success "Prerequisites installed."


# --- 2. Git Installation ---
log_info "Installing Git..."
sudo apt-get install -y git
log_success "Git installed successfully."
git --version


# --- 3. Zsh and Oh My Zsh Setup ---
log_info "Installing Zsh..."
sudo apt-get install -y zsh
log_success "Zsh installed."

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_info "Installing Oh My Zsh..."
    # The installer will try to change the shell, we'll handle it manually to be sure
    CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    log_success "Oh My Zsh installed."
else
    log_info "Oh My Zsh is already installed. Skipping."
fi

# --- Zsh Plugin Installation ---
log_info "Installing Zsh plugins: zsh-syntax-highlighting and zsh-autosuggestions..."
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
# Install zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi
# Install zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi

log_info "Activating Zsh plugins in .zshrc..."
# This replaces the default 'plugins=(git)' with the new list
sed -i 's/^plugins=(git)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' "$HOME/.zshrc"
log_success "Zsh plugins installed and activated."


# Set Zsh as the default shell if it's not already
if [ "$(basename "$SHELL")" != "zsh" ]; then
    log_info "Setting Zsh as the default shell for the current user..."
    # This requires the user's password
    chsh -s $(which zsh)
    log_success "Default shell changed to Zsh. Please log out and log back in for the change to take effect."
else
    log_info "Zsh is already the default shell."
fi


# --- 4. Nginx Installation ---
log_info "Installing Nginx..."
sudo apt-get install -y nginx
log_success "Nginx installed."

log_info "Starting and enabling Nginx service..."
sudo systemctl start nginx
sudo systemctl enable nginx
log_success "Nginx is active and enabled."


# --- 5. Certbot for Nginx Setup ---
log_info "Installing Certbot and the Nginx plugin..."
# Add Certbot PPA
#sudo add-apt-repository ppa:certbot/certbot -y
#sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx
log_success "Certbot installed successfully."


# --- 6. Docker Engine Installation ---
log_info "Setting up Docker repository..."
# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

log_info "Installing Docker Engine, CLI, and Containerd..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
log_success "Docker installed."

log_info "Starting and enabling Docker service..."
sudo systemctl start docker
sudo systemctl enable docker
log_success "Docker is active and enabled."

log_info "Adding current user to the 'docker' group to run Docker without sudo..."
sudo usermod -aG docker ${USER}
log_success "User '${USER}' added to the docker group."
log_warning "You need to log out and log back in for the group changes to apply."


# --- 7. Docker Compose Installation ---
log_info "Installing Docker Compose..."
# Find the latest version of Docker Compose
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$COMPOSE_VERSION" ]; then
    log_warning "Could not automatically determine latest Docker Compose version. Using a fallback."
    COMPOSE_VERSION="v2.27.0" # A recent stable version
fi

# Download and install
DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)"
sudo curl -L "$DOCKER_COMPOSE_URL" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
log_success "Docker Compose version ${COMPOSE_VERSION} installed."
docker-compose --version


# --- Final Summary ---
echo -e "\n\n\e[1;32m====================================================="
echo -e "         SETUP COMPLETE! 🎉"
echo -e "=====================================================\e[0m\n"
log_warning "IMPORTANT: To apply changes for Docker permissions and the Zsh shell, you must log out and log back in."
echo -e "After logging back in, you can configure your tools:\n"
echo -e "  - \e[1mGit:\e[0m"
echo -e "    git config --global user.name \"Your Name\""
echo -e "    git config --global user.email \"you@example.com\"\n"
echo -e "  - \e[1mNginx & Certbot:\e[0m"
echo -e "    Configure your Nginx server blocks in /etc/nginx/sites-available/"
echo -e "    Then run 'sudo certbot --nginx' to get SSL certificates.\n"
echo -e "  - \e[1mOh My Zsh:\e[0m"
echo -e "    Customize your setup by editing ~/.zshrc\n"

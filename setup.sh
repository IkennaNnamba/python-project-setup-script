#!/bin/bash

set -euo pipefail

LOG_FILE="setup.log"
VENV_DIR=".venv"
GITIGNORE_FILE=".gitignore"
DEFAULT_PACKAGES="pandas requests pre-commit"

# --- ANSI Color Codes ---
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No-color


# Clear log file and write startup timestamp
echo "--- $(date '+%Y-%m-%d %H:%M:%S'): STARTING SETUP ---" > "$LOG_FILE"

date_timestamp(){
  date +'%Y-%m-%d %H:%M:%S'
}

log_message() {
    local level=$1
    local message=$2
    # Logs timestamp, level, and message to the file
    echo "[ $(date_timestamp) ] [ ${level} ]: ${message}" >> "$LOG_FILE"
}

print_success(){
  echo -e "[ ${GREEN}SUCCESS${NC} ]: ${GREEN}$1${NC}"
  log_message "SUCCESS" "$1"
}

print_error(){
  echo -e "[ ${RED}ERROR${NC} ]: ${RED}$1${NC}" >&2
  log_message "ERROR" "$1"
  exit 1
}

print_warning(){
  echo -e "[ ${YELLOW}WARNING${NC} ]: $1"
  log_message "WARNING" "$1"
}

print_info(){
  echo -e "[ ${CYAN}INFO${NC} ]: ${CYAN}$1${NC}"
  log_message "INFO" "$1"
}

cleanup() {
    print_warning "Script interrupted by user (Ctrl+C). Starting cleanup..."

    # 1. Check if the virtual environment is currently active in the shell.
    # $VIRTUAL_ENV is set when the environment is active.
    if [ -n "$VIRTUAL_ENV" ]; then
        print_info "Deactivating active virtual environment..."
        # Deactivate, suppressing potential errors if the function is not in PATH
        deactivate 2>/dev/null
    fi

    # 2. Check if the Venv directory exists and remove it.
    if [ -d "$VENV_DIR" ]; then
        print_info "Removing partially created virtual environment directory ($VENV_DIR)..."
        rm -rf "$VENV_DIR"
        print_success "Cleanup successful. $VENV_DIR removed."
    else
        # This runs if the user cancels before venv_check runs
        print_success "Cleanup successful. No $VENV_DIR found to remove."
    fi

    print_info "The setup log ($LOG_FILE) has been retained for inspection."
    exit 1
}


venv_check() {
    print_info "Starting virtual environment check..."

    if [ -d "$VENV_DIR" ]; then
        print_warning "Virtual environment already exists. Proceeding to activation."
    else
        # VENV creation logic
        print_info "Creating virtual environment..."

        # the python command output is logged:
        python3 -m venv "$VENV_DIR" >> "$LOG_FILE" 2>&1 || \
            print_error "Virtual environment creation failed. Details are in '$LOG_FILE'."
        print_success "Virtual environment created successfully."
    fi

    # Activation logic
    print_info "Activating virtual environment..."
    # This command's output is also logged:
    source "$VENV_DIR/bin/activate" >> "$LOG_FILE" 2>&1 || \
        print_error "Virtual environment activation failed. Exiting."
    print_success "Virtual environment is now active."
}


upgrade_pip() {
    print_info "Ensuring pip is up to date..."
    print_info "NOTE: The update requires a download and may take time depending on your connection.\nPlease ensure your screen/terminal session remains active."
    # Execute the upgrade command. It uses the active virtual environment's pip.
    # Output is logged, and failure triggers print_error and exits the script.
    python -m pip install --upgrade pip >> "$LOG_FILE" 2>&1 || \
        print_error "Failed to upgrade pip. Check connectivity or review '$LOG_FILE'."
    print_success "Pip successfully upgraded to the latest version."
}


generate_gitignore() {
    print_info "Checking for $GITIGNORE_FILE..."

    if [ -f "$GITIGNORE_FILE" ]; then
        print_warning "$GITIGNORE_FILE already exists. Skipping creation."
    else
        print_info "Creating $GITIGNORE_FILE with standard Python rules..."
        cat << 'EOF' > "$GITIGNORE_FILE"
# --- Python Virtual Environments ---
.venv/
venv/

# --- Byte-compiled / cache files ---
__pycache__/
*.py[cod]
*$py.class

# --- Distribution / Packaging ---
build/
dist/
*.egg-info/
.eggs/
*.egg

# --- Logs and databases ---
*.log
*.sqlite3

# --- Unit test / coverage reports ---
.coverage
htmlcov/
.tox/
.nox/
.pytest_cache/

# --- IDE / Editor settings ---
.vscode/
.idea/
*.swp

# --- Jupyter Notebook checkpoints ---
.ipynb_checkpoints/

# --- Miscellaneous ---
.DS_Store
EOF

        # Check the exit status of the file write
        if [ $? -eq 0 ]; then
            print_success "$GITIGNORE_FILE created successfully."
            # Log a confirmation that content was added
            print_info "Standard Python ignore rules applied."
        else
            print_error "Failed to create $GITIGNORE_FILE. Check directory permissions."
        fi
    fi
}


install_packages() {
    print_info "Installing default Python packages: ${DEFAULT_PACKAGES}..."

    print_info "NOTE: Package installation requires downloading dependencies and may take time.\nPlease ensure your screen/terminal session remains active."
    python -m pip install ${DEFAULT_PACKAGES} >> "$LOG_FILE" 2>&1 || \
        print_error "Failed to install Python packages. Check connectivity or review '$LOG_FILE'."

    print_success "Required Python packages installed successfully."
}


script_complete() {
    print_success "=========================================================="
    print_success "SETUP COMPLETE! Your project environment is ready."
    print_success "   - Log file: $LOG_FILE"
    print_success "   - To enter the environment: source $VENV_DIR/bin/activate"
    print_success "=========================================================="
}


#---Trap set incase process was cancelled by User---
trap cleanup INT


# --- Main Script Execution Starts Here ---
main() {
    print_info "Starting project setup script..."

    # 1. Environment Setup
    venv_check       # Handles creation and activation
    upgrade_pip      # Ensures latest pip

    # 2. File & Dependency Setup
    generate_gitignore # Creates .gitignore (or skips)
    install_packages   # Installs pandas, requests, pre-commit

    # 3. Finalization
    script_complete
}

main

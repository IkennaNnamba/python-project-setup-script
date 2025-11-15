## 🐍 Python Project Environment Bootstrapper

### Project Description

This project provides a complete **Bash bootstrapper** for new Python development environments, designed to guarantee consistency and eliminate setup inconsistencies with a single command. It idempotently creates and activates the `.venv`, manages core dependencies by upgrading **pip** and installing essential packages (**pandas, requests, pre-commit**), and ensures a clean repository structure by generating a **`.gitignore`** file. The script's primary goal is to ensure that a project is initialized correctly the first time, every time.

For professional-grade robustness, the script provides a superior user experience by using **colored output on the terminal screen** for clear, immediate status updates. Simultaneously, all actions, command outputs, and diagnostic details are written as **plain, structured text** to the **`setup.log`** file for full accountability. A critical **TRAP handler** is included to manage user interruptions ($\text{Ctrl}+\text{C}$), safely cleaning up the shell environment and deleting any partial Venv directory while preserving the diagnostic log file for analysis.

---

### What the Script Does

The `setup.sh` script automates the complete initialization of a new Python project by executing the following sequential and idempotent steps:

1.  **Initialization:** Creates log file if there wasn't one or clears the previous `setup.log` and starts the logging sequence.
2.  **Venv Setup & Activation:** Checks for the `.venv` directory and activates. If missing, it creates it and immediately activates it within the script's scope.
3.  **Maintenance:** Upgrades **pip** to the latest version inside the active environment.
4.  **Configuration:** Conditionally creates a standard **`.gitignore`** file for Python projects, skipping if the file already exists.
5.  **Dependencies:** Installs core packages defined in `DEFAULT_PACKAGES` (**pandas, requests, pre-commit**).
6.  **Error Handling (TRAP):** A `trap INT` is active throughout the process, ensuring that if the user presses $\text{Ctrl}+\text{C}$, any partially created Venv is **deactivated and deleted**, preserving the diagnostic log.
7.  **Completion:** Prints a final success message and instructions for manual activation.

---

### How to Execute It

Assuming you are in the project root directory and have Bash and Python 3 installed:

1.  **Make the script executable:**
    ```bash
    chmod +x setup.sh
    ```
2.  **Run the script:**
    ```bash
    ./setup.sh
    ```
3.  **Enter the environment manually** (after the script completes):
    ```bash
    source .venv/bin/activate
    ```

---

### Example Outputs

#### 1.  **Testing the Trap and Cleanup function. (Cancelled process with Ctrl + C)**

```bash
ikenna@IKENNA-T490:~/scripts$ ./setup.sh
[ ℹ️ INFO ] : Starting virtual environment check...
[ ℹ️ INFO ] : Creating virtual environment...
[ ✅ SUCCESS ]: **Virtual environment created successfully.**
[ ℹ️ INFO ] : Activating virtual environment...
[ ✅ SUCCESS ]: **Virtual environment is now active.**
[ ℹ️ INFO ] : Ensuring pip is up to date...
^C[ ⚠️ WARNING ]: Script interrupted by user (Ctrl+C). Starting cleanup...
[ ℹ️ INFO ] : Deactivating active virtual environment...
[ ℹ️ INFO ] : Removing partially created virtual environment directory (.venv)...
[ ✅ SUCCESS ]: **Cleanup successful. .venv removed.**
[ ℹ️ INFO ] : The setup log (setup.log) has been retained for inspection.`
```
#### 2. **Venv Already Exists, Full Setup Continuation**

```bash
ikenna@IKENNA-T490:~/scripts$ ./setup.sh
[ ℹ️ INFO ] : Starting virtual environment check...
[ ⚠️ WARNING ]: Virtual environment already exists. Proceeding to activation.
[ ℹ️ INFO ] : Activating virtual environment...
[ ✅ SUCCESS ]: **Virtual environment is now active.**
[ ℹ️ INFO ] : Ensuring pip is up to date...
[ ℹ️ INFO ] : NOTE: The update requires a download and may take time depending on your connection.
Please ensure your screen/terminal session remains active.
[ ✅ SUCCESS ]: **Pip successfully upgraded to the latest version.**
[ ℹ️ INFO ] : Checking for .gitignore...
[ ℹ️ INFO ] : Creating .gitignore with standard Python rules...
[ ✅ SUCCESS ]: **.gitignore created successfully.**
[ ℹ️ INFO ] : Standard Python ignore rules applied.
[ ℹ️ INFO ] : Installing default Python packages: pandas requests pre-commit...
[ ℹ️ INFO ] : NOTE: Package installation requires downloading dependencies and may take time.
Please ensure your screen/terminal session remains active.
[ ✅ SUCCESS ]: **Required Python packages installed successfully.**
[ ✅ SUCCESS ]: ==========================================================
[ ✅ SUCCESS ]: **SETUP COMPLETE! Your project environment is ready.**
[ ✅ SUCCESS ]:    - Log file: setup.log
[ ✅ SUCCESS ]:    - To enter the environment: source .venv/bin/activate
[ ✅ SUCCESS ]: ==========================================================
```
#### 3. **Idempotency Test: Venv and .gitignore Exist**

```bash
ikenna@IKENNA-T490:~/scripts$ ./setup.sh
[ ℹ️I NFO ]: Starting project setup script...
[ ℹ️ INFO ] : Starting virtual environment check...
[ ⚠️ WARNING ]: Virtual environment already exists. Proceeding to activation.
[ ℹ️ INFO ] : Activating virtual environment...
[ ✅ SUCCESS ]: **Virtual environment is now active.**
[ ℹ️ INFO ] : Ensuring pip is up to date...
[ ℹ️ INFO ] : NOTE: The update requires a download and may take time depending on your connection.
Please ensure your screen/terminal session remains active.
[ ✅ SUCCESS ]: **Pip successfully upgraded to the latest version.**
[ ℹ️ INFO ] : Checking for .gitignore...
[ ⚠️ WARNING ]: .gitignore already exists. Skipping creation.
[ ℹ️ INFO ] : Installing default Python packages: pandas requests pre-commit...
[ ℹ️ INFO ] : NOTE: Package installation requires downloading dependencies and may take time.
Please ensure your screen/terminal session remains active.
[ ✅ SUCCESS ]: **Required Python packages installed successfully.**
[ ✅ SUCCESS ]: ==========================================================
[ ✅ SUCCESS ]: **SETUP COMPLETE! Your project environment is ready.**
[ ✅ SUCCESS ]:    - Log file: setup.log
[ ✅ SUCCESS ]:    - To enter the environment: source .venv/bin/activate
[ ✅ SUCCESS ]: ==========================================================
```

### Challenges faced and lessons learned


#### 1. Robustness and Graceful Cleanup (TRAP Handler)

A key challenge arose when debugging initial failures, revealing that even when a subsequent command failed (like the `pip upgrade` shown below), the script left behind a partially configured environment.

#### The Issue

The error output highlighted two critical problems: a persistent typo (`date_timestamp: command not found`) and the script exiting after being cancelled by the user but outputing an error relating to failed `pip upgrade` attempt, leaving the newly created `.venv` directory behind:

```bash
ikenna@IKENNA-T490:~/scripts$ ./setup.sh
[ ℹ️ INFO ] : Starting virtual environment check...
./setup.sh: line 29: date_timestamp: command not found
[ ℹ️ INFO ] : Creating virtual environment...
./setup.sh: line 29: date_timestamp: command not found
[ ✅ SUCCESS ]: Virtual environment created successfully.
./setup.sh: line 29: date_timestamp: command not found
[ ℹ️ INFO ] : Activating virtual environment...
./setup.sh: line 29: date_timestamp: command not found
[ ✅ SUCCESS ]: Virtual environment is now active.
[ ℹ️ INFO ] : Ensuring pip is up to date...
./setup.sh: line 29: date_timestamp: command not found
^C[ ❌ ERROR ]: Failed to upgrade pip. Check connectivity or review 'setup.log'.
./setup.sh: line 29: date_timestamp: command not found
```

This scenario made it clear that basic error handling (`set -e` or `print_error`) was insufficient. I needed to implement a custom signal handler using the trap INT command.

#### The final cleanup function was designed to:

* Catch the Ctrl+C signal instantly
* Safely deactivate the environment using the `$VIRTUAL_ENV` check
* Delete the partial `.venv` directory (`rm -rf "$VENV_DIR"`)
* Preserve the diagnostic log file for inspection

#### 2. Understanding Here Documents and Quoting (<<EOF)
When writing the .gitignore file, I encountered the behavior of Here Documents (`cat <<EOF`):

* Unquoted Delimiter (`<<EOF`) 
I learned that an unquoted delimiter allows shell variable expansion within the document content. This means if the `.gitignore` accidentally contained a dollar sign like `$HOME` (in my case `$py.class` which was intailly picked up by `set -u` command), the shell would try to replace it with a variable value, potentially corrupting the output file.

* Quoted Delimiter (`<<'EOF'`)
I adopted the best practice of quoting the delimiter (`<<'EOF'`). The quotes prevent any form of expansion or interpretation by the shell, ensuring that the content— which is a static configuration file—is written literally to the `.gitignore` file.

This provided necessary security and consistency.


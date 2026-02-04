# Xonsh Configuration Security & Best Practices Guide

**File:** `~/.xonshrc` (home-manager/modules/dotfiles/xonshrc)

This document audits all aliases, functions, and configurations for safety, command injection risks, and alternative approaches.

---

## 🔴 HIGH RISK - Requires Immediate Attention

### 1. `gup` - Git Sync (Lines 100-108)

**Function:**
```python
def git_sync(args):
    branch = args[0]
    commit_message = args[1]
    os.system('cd .')
    os.system('git fetch')
    os.system(f'git pull origin {branch}')
    os.system('git add .')
    os.system(f'git commit -m "{commit_message}"')
    os.system(f'git push -u origin {branch}')
```

**Risks:**
- ⚠️ **Quote Injection:** Commit message is not escaped. Input: `gup main "msg; rm -rf ."` would execute arbitrary commands
- ⚠️ **No Review:** Stages ALL changes without letting user review diffs
- ⚠️ **No Error Handling:** Fails silently if git commands fail
- ⚠️ **No Confirmation:** Pushes to remote immediately without verification
- ⚠️ **Atomic Operation Failure:** If push fails, commit is already made

**Safer Alternatives:**

**Option A: Manual Git Workflow (SAFEST)**
```bash
git add <specific-files>    # Review what you're adding
git diff --staged           # Review exact changes
git commit -m "message"     # Explicit commit
git push origin <branch>    # Explicit push
```

**Option B: Interactive Git Wrapper with Confirmation**
```python
def git_sync_safe(args):
    """Safer git sync with confirmation steps"""
    if len(args) < 2:
        print("Usage: gup <branch> <message>")
        return

    branch = args[0]
    commit_message = args[1]

    # Show what will be staged
    os.system('git status --short')
    response = input("Stage all changes? (y/N): ")
    if response.lower() != 'y':
        return

    # Show diff before commit
    os.system('git add .')
    os.system('git diff --staged')
    response = input("Commit with message: '{}'? (y/N): ".format(commit_message))
    if response.lower() != 'y':
        os.system('git reset')
        return

    # Commit and push with error checking
    ret = os.system(f'git commit -m "{commit_message}"')
    if ret != 0:
        print("Commit failed, skipping push")
        return

    ret = os.system(f'git push -u origin {branch}')
    if ret != 0:
        print("Push failed - commit is local")
```

**Option C: Use subprocess for Safe Command Execution**
```python
import subprocess

def git_sync_subprocess(args):
    """Git sync using subprocess (safer than os.system)"""
    branch = args[0]
    message = args[1]

    try:
        subprocess.run(['git', 'fetch'], check=True)
        subprocess.run(['git', 'pull', 'origin', branch], check=True)
        subprocess.run(['git', 'add', '.'], check=True)
        subprocess.run(['git', 'commit', '-m', message], check=True)
        subprocess.run(['git', 'push', '-u', 'origin', branch], check=True)
        print("✓ Push successful")
    except subprocess.CalledProcessError as e:
        print(f"✗ Git command failed: {e}")
        return
```

**Recommendation:** Use Option B or C. Avoid using `gup` for production branches without manual review.

---

### 2. `set_wallpaper()` - Command Injection (Lines 51-68)

**Function:**
```python
def set_wallpaper(args):
    if not args:
        print("Usage: set_wallpaper <option> or <wallpaper_name>")
        return None
    option = args[0]
    if option == "ls":
        os.system(f'eza --icons {WALLPAPER_DIR}')  # ⚠️ INJECTION RISK
        return None
    wallpaper = option
    for root, dirs, files in os.walk(WALLPAPER_DIR):
        for file in files:
            name, ext = os.path.splitext(file)
            if name == wallpaper or file == wallpaper:
                os.system(f'cp "{os.path.join(WALLPAPER_DIR, file)}" ...')  # ⚠️ PATH INJECTION
                os.system('i3 restart')  # ⚠️ SHELL INJECTION
                return None
```

**Risks:**
- ⚠️ **Path Traversal:** Input: `wp ../../etc/passwd` could access parent directories
- ⚠️ **Command Injection in i3 restart:** If wallpaper path contains backticks/`$()`, could execute commands
- ⚠️ **Unsafe os.system():** All calls should use subprocess with list args

**Safe Alternative:**
```python
import subprocess
import shlex

def set_wallpaper_safe(args):
    """Safely set wallpaper with validation"""
    if not args:
        print("Usage: set_wallpaper <option> or <wallpaper_name>")
        return

    option = args[0]
    if option == "ls":
        try:
            subprocess.run(['eza', '--icons', WALLPAPER_DIR], check=True)
        except subprocess.CalledProcessError:
            print("Failed to list wallpapers")
        return

    wallpaper = option
    wallpaper_path = None

    for root, dirs, files in os.walk(WALLPAPER_DIR):
        for file in files:
            name, ext = os.path.splitext(file)
            if name == wallpaper or file == wallpaper:
                # Ensure path is within WALLPAPER_DIR (prevent traversal)
                full_path = os.path.join(root, file)
                if not os.path.abspath(full_path).startswith(os.path.abspath(WALLPAPER_DIR)):
                    print("Error: Path traversal detected")
                    return
                wallpaper_path = full_path
                break
        if wallpaper_path:
            break

    if not wallpaper_path:
        print(f"Error: Wallpaper '{wallpaper}' not found")
        return

    try:
        dest = os.path.join(WALLPAPER_DIR, 'wallpaper')
        subprocess.run(['cp', wallpaper_path, dest], check=True)
        subprocess.run(['i3', 'restart'], check=True)
        print(f"✓ Wallpaper changed to {wallpaper}")
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
```

---

### 3. `set_display()` - Command Injection (Lines 70-73)

**Function:**
```python
def set_display(mode):
    os.system(f'autorandr -l {mode[0]}')  # ⚠️ NO VALIDATION
    os.system('i3 restart')
    return None
```

**Risks:**
- ⚠️ **No validation:** `mode[0]` is unsanitized
- ⚠️ **Command injection:** Input: `d "; rm -rf /"` would be dangerous
- ⚠️ **No error handling**

**Safe Alternative:**
```python
def set_display_safe(args):
    """Safely change display configuration"""
    if not args:
        print("Usage: set_display <profile>")
        return

    profile = args[0]

    # Validate profile name (alphanumeric, hyphens, underscores only)
    if not re.match(r'^[a-zA-Z0-9_-]+$', profile):
        print(f"Error: Invalid profile name '{profile}'")
        return

    try:
        subprocess.run(['autorandr', '-l', profile], check=True)
        subprocess.run(['i3', 'restart'], check=True)
        print(f"✓ Display profile changed to {profile}")
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
```

---

## 🟡 MEDIUM RISK - Use with Caution

### 4. `webup` - HTTP Server (Line 178)

**Alias:**
```bash
'webup': 'python3 -m http.server 8080'
```

**Risks:**
- ⚠️ **No Authentication:** Serves all files to anyone on network
- ⚠️ **No HTTPS/SSL:** Transmitted in cleartext
- ⚠️ **No Access Control:** No ability to restrict file access
- ⚠️ **Serves Root:** Starts from current directory, could expose sensitive files
- ✓ **OK for:** Local development only (localhost)
- ✗ **NOT OK for:** Production, shared networks, sensitive data

**Safe Usage:**
```bash
# SAFE: Single file, read-only
python3 -m http.server 8080 --directory /tmp/share

# SAFE: Behind localhost only
python3 -m http.server 8080 --bind 127.0.0.1 8080

# BETTER: Use with authentication
# Option A: Simple authentication wrapper (create script)
# Option B: Use nginx with auth
# Option C: Use Python SimpleHTTPServer with auth
```

**Keep as-is, but add documentation:**
```bash
'webup': 'python3 -m http.server 8080'  # LOCAL DEVELOPMENT ONLY - no auth, no SSL
```

---

### 5. `untar` - Wildcard Expansion Risk (Line 152)

**Alias:**
```bash
'untar': 'tar -xf *.tar.xz'
```

**Risks:**
- ⚠️ **Wildcard Expansion:** If multiple `.tar.xz` files exist, undefined behavior
- ⚠️ **No Directory Validation:** Could extract malicious files to system directories
- ✓ **Moderate Risk:** Unlikely in normal usage

**Better Alternative:**
```bash
'untar': 'tar -xf'  # Require explicit filename
# Usage: untar file.tar.xz

# OR use function with validation:
def untar_safe(args):
    if not args:
        print("Usage: untar <file.tar.xz>")
        return

    filename = args[0]
    if not filename.endswith(('.tar.xz', '.tar.gz', '.tar.bz2', '.tar')):
        print("Error: Not a valid tar archive")
        return

    if not os.path.exists(filename):
        print(f"Error: File not found: {filename}")
        return

    subprocess.run(['tar', '-xf', filename], check=True)
```

---

## 🟢 LOW RISK - Generally Safe

### 6. `command_output()` - Unused Function (Lines 25-27)

**Status:** ✓ **SAFE TO REMOVE** - Not used anywhere

```python
def command_output(command):
    result = subprocess.check_output(command).decode('utf-8')
    return result.strip()
```

**Action:** Delete these lines - they serve no purpose.

---

### 7. Safe Aliases

✓ **Safe to keep:**
- `rebuild`, `hms` - NixOS commands, no injection risk
- `v`, `c` - Simple shortcuts
- `ls`, `ll`, `la`, `lla`, `cat` - Tool replacements (eza, bat)
- `neo`, `code` - Tool shortcuts
- `xc` - xclip, safe
- `bak` - cp with recursive flag, safe
- `mkvenv`, `vac`, `vdac`, `vls` - uvox Python environment, safe
- `ipv4` - Socket-based IP detection, safe
- Prompt functions - Safe

---

## 📋 Summary & Action Items

| Component | Risk | Status | Action |
|-----------|------|--------|--------|
| `gup` (git_sync) | HIGH | Active | Replace with safer alternative or add confirmation prompts |
| `set_wallpaper` | HIGH | Active | Rewrite with subprocess, validate paths |
| `set_display` | HIGH | Active | Add input validation, use subprocess |
| `webup` | MEDIUM | Active | Keep but add documentation warning |
| `untar` | MEDIUM | Active | Remove wildcard, require explicit filename |
| `command_output` | LOW | Unused | Delete function |
| All other aliases | LOW | Active | Keep as-is |

---

## 🛡️ Best Practices Applied

1. **Use subprocess instead of os.system()**
   - `os.system()` spawns a shell, enabling injection attacks
   - `subprocess.run(['cmd', 'arg1', 'arg2'], check=True)` is safer - no shell involved

2. **Never interpolate user input into shell commands**
   - ✗ Bad: `os.system(f'command {user_input}')`
   - ✓ Good: `subprocess.run(['command', user_input], check=True)`

3. **Validate and sanitize input**
   - ✓ Check file paths exist and are within expected directory
   - ✓ Use regex to validate profile names, branch names, etc.
   - ✓ Reject unexpected characters

4. **Always check return codes**
   - ✓ Use `check=True` in subprocess.run()
   - ✓ Use try/except for CalledProcessError

5. **Add confirmation prompts for destructive operations**
   - ✓ Ask before staging/committing/pushing
   - ✓ Show diff before committing
   - ✓ Show affected files before deletion

6. **Document security implications**
   - ✓ Add comments about what each function does
   - ✓ Note risks and limitations
   - ✓ Suggest safer alternatives

---

## 📝 Next Steps

1. **Immediately:** Remove `command_output()` function (unused, low value)
2. **Soon:** Replace `gup` with safer git workflow or subprocess-based wrapper
3. **Important:** Rewrite `set_wallpaper` and `set_display` with proper validation
4. **Document:** Add comments to `webup` warning about localhost-only usage
5. **Refine:** Update `untar` to require explicit filename

---

## References

- [Python subprocess documentation](https://docs.python.org/3/library/subprocess.html)
- [OWASP: Command Injection](https://owasp.org/www-community/attacks/Command_Injection)
- [Shell Injection Risk](https://en.wikipedia.org/wiki/Shell_injection)
- [Python Security Best Practices](https://python.readthedocs.io/en/latest/library/security_warnings.html)

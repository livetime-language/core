#!/usr/bin/env bash
#
# setupAndroidSDKonMacOS.sh
#
# One-shot setup for building this Capacitor app on a fresh macOS machine with:
#
#     npx cap run android
#
# It installs Eclipse Temurin 21 (the JDK the Android/Capacitor plugins require)
# and wires up the Android SDK, configuring everything at the USER/SYSTEM level.
# Nothing inside the project repository is modified, so the project stays
# portable across machines and operating systems.
#
# What it configures (all outside the repo):
#   * Eclipse Temurin 21 JDK (via Homebrew cask, installed to /Library/...)
#   * ~/.gradle/gradle.properties:
#       - org.gradle.java.home              -> run the Gradle daemon on JDK 21
#                                              (fixes "invalid source release: 21")
#       - org.gradle.java.installations.paths -> let the toolchain resolver find
#                                              JDK 21 (fixes "Cannot find a Java
#                                              installation ... matching 21")
#   * Android SDK + ANDROID_HOME / PATH in your shell profile (if not already set)
#
# The script is idempotent: re-running it is safe and only fills in what's missing.
#
# Usage:
#   ./setupAndroidSDKonMacOS.sh
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Pretty logging
# ---------------------------------------------------------------------------
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; BLUE=$'\033[34m'; RESET=$'\033[0m'
else
  BOLD=""; GREEN=""; YELLOW=""; RED=""; BLUE=""; RESET=""
fi
info()  { printf '%s==>%s %s\n' "${BLUE}${BOLD}" "${RESET}" "$*"; }
ok()    { printf '%s  ok%s %s\n' "${GREEN}" "${RESET}" "$*"; }
warn()  { printf '%s warn%s %s\n' "${YELLOW}" "${RESET}" "$*"; }
die()   { printf '%serror%s %s\n' "${RED}${BOLD}" "${RESET}" "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 0. Sanity checks
# ---------------------------------------------------------------------------
[[ "$(uname -s)" == "Darwin" ]] || die "This script is for macOS only."

REQUIRED_JDK=21
GRADLE_PROPS="$HOME/.gradle/gradle.properties"

# ---------------------------------------------------------------------------
# 1. Homebrew
# ---------------------------------------------------------------------------
info "Checking for Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  # Add the common install locations to PATH in case brew is installed but not yet on PATH.
  for cand in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$cand" ]] && eval "$("$cand" shellenv)"
  done
fi
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew (you may be prompted for your password)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  for cand in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$cand" ]] && eval "$("$cand" shellenv)"
  done
fi
command -v brew >/dev/null 2>&1 || die "Homebrew is required but could not be installed."
ok "Homebrew: $(brew --version | head -1)"

# ---------------------------------------------------------------------------
# 2. Eclipse Temurin 21 JDK
# ---------------------------------------------------------------------------
# Locate a JDK whose major version is exactly $REQUIRED_JDK. /usr/libexec/java_home
# only scans /Library, so we also probe user-level install locations.
jdk21_home() {
  local h
  h="$(/usr/libexec/java_home -v "$REQUIRED_JDK" 2>/dev/null || true)"
  if [[ -n "$h" && -x "$h/bin/java" ]]; then echo "$h"; return; fi
  local cand
  for cand in \
    "$HOME/Library/Java/JavaVirtualMachines"/*/Contents/Home \
    /Library/Java/JavaVirtualMachines/*/Contents/Home \
    /opt/homebrew/opt/openjdk@"${REQUIRED_JDK}"/libexec/openjdk.jdk/Contents/Home; do
    [[ -x "$cand/bin/java" ]] || continue
    if "$cand/bin/java" -version 2>&1 | grep -qE "version \"${REQUIRED_JDK}(\.|\")"; then
      echo "$cand"; return
    fi
  done
}

info "Checking for a Java ${REQUIRED_JDK} JDK..."
JAVA21_HOME="$(jdk21_home)"
if [[ -z "$JAVA21_HOME" ]]; then
  info "Installing Eclipse Temurin ${REQUIRED_JDK} (a system install; you may be prompted for your password)..."
  brew install --cask "temurin@${REQUIRED_JDK}"
  JAVA21_HOME="$(jdk21_home)"
fi
[[ -n "$JAVA21_HOME" && -x "$JAVA21_HOME/bin/java" ]] \
  || die "Java ${REQUIRED_JDK} still not found after install. Check 'brew install --cask temurin@${REQUIRED_JDK}'."
ok "Java ${REQUIRED_JDK}: $JAVA21_HOME"
"$JAVA21_HOME/bin/java" -version

# ---------------------------------------------------------------------------
# 3. Gradle: run the daemon on JDK 21 and register it for the toolchain resolver
#    (~/.gradle/gradle.properties is per-user and applies to every Gradle build,
#     so the project itself needs no changes.)
# ---------------------------------------------------------------------------
info "Configuring ${GRADLE_PROPS} ..."
mkdir -p "$HOME/.gradle"
touch "$GRADLE_PROPS"

BEGIN="# >>> setupAndroidSDKonMacOS (managed) >>>"
END="#   <<< setupAndroidSDKonMacOS (managed) <<<"

# Strip any previously managed block so re-runs stay clean.
if grep -qF "$BEGIN" "$GRADLE_PROPS"; then
  tmp="$(mktemp)"
  awk -v b="$BEGIN" -v e="$END" '
    $0==b {skip=1}
    skip==0 {print}
    $0==e {skip=0}
  ' "$GRADLE_PROPS" > "$tmp"
  mv "$tmp" "$GRADLE_PROPS"
fi

{
  printf '%s\n' "$BEGIN"
  printf '# Required by this Capacitor/Android project. Managed by setupAndroidSDKonMacOS.sh.\n'
  printf '# Run the Gradle daemon on JDK %s (fixes "invalid source release: %s").\n' "$REQUIRED_JDK" "$REQUIRED_JDK"
  printf 'org.gradle.java.home=%s\n' "$JAVA21_HOME"
  printf '# Let the Java toolchain resolver find JDK %s.\n' "$REQUIRED_JDK"
  printf 'org.gradle.java.installations.paths=%s\n' "$JAVA21_HOME"
  printf '%s\n' "$END"
} >> "$GRADLE_PROPS"
ok "Gradle will use JDK ${REQUIRED_JDK} for the daemon and toolchain."

# ---------------------------------------------------------------------------
# 4. Android SDK + environment
# ---------------------------------------------------------------------------
info "Checking for an Android SDK..."

# Resolve an existing SDK from the usual places.
detect_sdk() {
  for c in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$HOME/Library/Android/sdk"; do
    [[ -n "$c" && -d "$c" ]] && { echo "$c"; return; }
  done
}
SDK_DIR="$(detect_sdk)"

if [[ -z "$SDK_DIR" ]]; then
  info "Installing Android command-line tools..."
  brew install --cask android-commandlinetools
  # Homebrew exposes sdkmanager on PATH; use a standard, writable SDK root.
  SDK_DIR="$HOME/Library/Android/sdk"
  mkdir -p "$SDK_DIR"
  if command -v sdkmanager >/dev/null 2>&1; then
    info "Installing platform-tools, build-tools, a platform and the emulator (accepting licenses)..."
    yes | sdkmanager --sdk_root="$SDK_DIR" \
      "platform-tools" "emulator" \
      "platforms;android-34" "build-tools;34.0.0" >/dev/null || \
      warn "sdkmanager package install hit an issue; you can re-run it manually."
    yes | sdkmanager --sdk_root="$SDK_DIR" --licenses >/dev/null || true
  else
    warn "sdkmanager not found on PATH after install; you may need to open a new terminal."
  fi
fi

if [[ -n "$SDK_DIR" && -d "$SDK_DIR" ]]; then
  ok "Android SDK: $SDK_DIR"

  # Persist ANDROID_HOME / PATH in the user's zsh profile (idempotent block).
  PROFILE="$HOME/.zshrc"
  touch "$PROFILE"
  PBEGIN="# >>> setupAndroidSDKonMacOS (Android SDK) >>>"
  PEND="#   <<< setupAndroidSDKonMacOS (Android SDK) <<<"
  if grep -qF "$PBEGIN" "$PROFILE"; then
    tmp="$(mktemp)"
    awk -v b="$PBEGIN" -v e="$PEND" '$0==b{skip=1} skip==0{print} $0==e{skip=0}' "$PROFILE" > "$tmp"
    mv "$tmp" "$PROFILE"
  fi
  {
    printf '%s\n' "$PBEGIN"
    printf 'export ANDROID_HOME="%s"\n' "$SDK_DIR"
    printf 'export ANDROID_SDK_ROOT="%s"\n' "$SDK_DIR"
    printf 'export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"\n'
    printf '%s\n' "$PEND"
  } >> "$PROFILE"
  ok "ANDROID_HOME / PATH written to $PROFILE"
else
  warn "No Android SDK configured. Install Android Studio or re-run this script with network access."
fi

# ---------------------------------------------------------------------------
# 5. Done
# ---------------------------------------------------------------------------
echo
info "${BOLD}Setup complete.${RESET}"
cat <<EOF

Next steps:
  1. Open a NEW terminal (so ANDROID_HOME / PATH take effect), or run:
         source ~/.zshrc
  2. Make sure a device is connected or an emulator is running:
         adb devices
  3. Build & run the app:
         npx cap run android

Notes:
  * Your system default Java is unchanged. Only Gradle is pinned to JDK ${REQUIRED_JDK},
    via ~/.gradle/gradle.properties — nothing in the project repo was modified.
  * To see what Gradle detected:  (cd android && ./gradlew -q javaToolchains)
EOF

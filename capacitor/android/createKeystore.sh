#!/bin/sh
#
# createKeystore.sh
#
# Creates the signing key of a Capacitor Android app:
#   android/app.keystore        RSA 4096 key, valid for 10000 days (as Google Play requires)
#   android/keystore.properties passwords and alias, read by android/app/build.gradle
#
# Commit both files, so builds from every machine have the same signature and update existing installs.
# Anyone who has them can sign updates of the app, so only commit them to a private repository.
# The key also qualifies as the Google Play app signing key: when setting up Play App Signing, choose to
# upload your own key ("Export and upload a key from Java keystore") before the first release.
#
# Run only once: Android refuses to update an installed app that was signed with a different key.
#
# Usage (from the project folder, which contains android/):
#   lib/core/android/createKeystore.sh
#
# Then sign all build types with it in android/app/build.gradle:
#   android {
#       signingConfigs {
#           shared {
#               def props = new Properties()
#               rootProject.file('keystore.properties').withInputStream { props.load(it) }
#               storeFile rootProject.file(props.storeFile)
#               storePassword props.storePassword
#               keyAlias props.keyAlias
#               keyPassword props.keyPassword
#           }
#       }
#       buildTypes {
#           debug { signingConfig signingConfigs.shared }
#           release { signingConfig signingConfigs.shared }
#       }
#   }
#
set -e
name=$(basename "$PWD")
cd android

if [ -e keystore.properties ]; then
	echo "android/keystore.properties already exists. Replacing the key would prevent updates of installed apps." >&2
	exit 1
fi

password=$(openssl rand -hex 16)
keytool -genkeypair -keystore app.keystore -storetype PKCS12 -alias app \
	-keyalg RSA -keysize 4096 -validity 10000 \
	-dname "CN=$name" -storepass "$password" -keypass "$password"

cat > keystore.properties <<EOF
storeFile=app.keystore
storePassword=$password
keyAlias=app
keyPassword=$password
EOF

keytool -list -v -keystore app.keystore -storepass "$password" | grep -E "Owner|Valid|SHA256:"

# Add Android target to capacitor app
npm i @capacitor/android
npx cap add android

# Add Android target to .livetime/targets.tc
mkdir -p .livetime
grep -qs "npx cap run android" .livetime/targets.lc || printf '\nAndroid\n\tTags: capacitor\n\tRunAfterBuild: npx cap run android --target 204564ea\n' >> .livetime/targets.lc
